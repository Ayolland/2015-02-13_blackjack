require 'pry'
require 'sinatra'
require 'sqlite3'
require 'card_deck'
include CardDeck
require_relative 'models/shoe'
require_relative 'models/card_values'
require_relative 'models/players'

DATABASE = SQLite3::Database.new('database/database.db')
require_relative "database/database_setup.rb"

get "/test" do
  @hand = test_hand
  erb :test
end

get "/" do
  erb :login
end

post "/verify" do
  username = params[:username]
  password = params[:password]
  if verify?(username,password) 
    @player = Player.new(load(username))
    @username = username
    erb :landing
  else
    @error = "Sorry, that username and password don't match!"
    erb :login
  end
end

post "/new_user" do
  erb :new_user
end

post "/create" do
  hash = {}
  hash["username"] = params[:username]
  hash["password"] = params[:password]
  hash["re_enter"] = params[:re_enter]
  hash["name"]     = params[:name]
  hash["gender"]   = params[:gender]
  hash["chips"]    = 500
  exists = load(hash["username"])
  if exists == nil && hash["password"] == hash["re_enter"]
    insert_user(hash)
    @player = Player.new(load(hash["username"]))
    @username = hash["username"]
    erb :landing
  elsif exists != nil
    @error = "Sorry, that username is taken already."
    erb :new_user
  elsif hash["password"] != hash["re_enter"]
    @error = "Sorry, that password did not match."
    erb :new_user
  end
end

get "/style_test" do
  hash = load("cassiegurl")
  hash["hand"] = test_hand
  @player = Player.new(hash)
  @dealer = Dealer.new({"hand" => test_hand, "min" => 5})
  @bet = 10
  erb :blackjack
end

post "/new_game/:username" do
  @username = params[:username]
  load_pl_de
  new_game
  erb :blackjack
end

post "/first_deal/:username" do
  @username = params[:username]
  @bet = params[:bet].to_i
  load_pl_de
  @player.chips -= @bet
  first_deal
  save_game_state
  erb :blackjack
end

post "/hit/:username" do
  @username = params[:username]
  load_pl_de
  @dealer.hand, @player.hand, @bet = load_game_state
  hit
  save_game_state
  erb :blackjack
end

post "/stand/:username" do
  @username = params[:username]
  load_pl_de
  @dealer.hand, @player.hand, @bet = load_game_state
  stand
  save_game_state
  erb :blackjack
end

post "/double/:username" do
  @username = params[:username]
  load_pl_de
  @dealer.hand, @player.hand, @bet = load_game_state
  double
  save_game_state
  erb :blackjack
end

post "/logout" do
  @error = "Thanks for playing and come back soon!"
  erb :login
end

helpers do
  
  def load_pl_de
    @dealer = Dealer.new({})
    @player = Player.new(load(@username))
  end
  
  def save_game_state
    DATABASE.execute('DELETE FROM Dealer')
    DATABASE.execute('DELETE FROM Player')
    DATABASE.execute('DELETE FROM Bet')
    @dealer.hand.each do |card|
      DATABASE.execute("INSERT INTO Dealer (card) VALUES ('#{card.to_s}')")
    end
    @player.hand.each do |card|
      DATABASE.execute("INSERT INTO Player (card) VALUES ('#{card.to_s}')")
    end
    DATABASE.execute ("INSERT INTO Bet (bet) VALUES (#{@bet})")
    DATABASE.execute ("UPDATE Users SET chips=#{@player.chips} WHERE username = '#{@username}'")    
  end
  
  def load_game_state
    temp = DATABASE.execute('SELECT * FROM Dealer')
    dealer = temp.each_with_object([]){|hash,array| array << hash[1]}
    temp = DATABASE.execute('SELECT * FROM Player')
    player = temp.each_with_object([]){|hash,array| array << hash[1]}
    temp = DATABASE.execute('SELECT * FROM Bet')
    bet = temp[0][1]
    return dealer, player, bet
  end
  
  def new_game
    @printer = []
    @action = :bet
    @dealer.hand = []
    @player.hand = []
    @bet = 0
    chat
  end
  
  def first_deal
    @printer = []
    @action = :choice
    deal_dealer
    de_total
    2.times {deal_player}
    pl_total
    chat
  end
  
  def hit
    @printer = []
    @printer << "You Hit."
    deal_player
    pl_total
    if @player.bust? || @player.hand_total == 21
      @action = :end
      run_dealer
    else
      @action = :choice
    end
    chat
  end
  
  def stand
    @printer = []
    @printer << "You Stand."
    pl_total
    @action = :end
    run_dealer
    chat
  end
  
  def double
    @printer = []
    @printer << "You double your bet and take one more card."
    @player.chips -= @bet
    @bet += @bet
    deal_player
    pl_total
    @action = :end
    run_dealer
    chat
  end
  
  def run_dealer
    loop do
      deal_dealer
      de_total
      break if @dealer.hand_total >=17 || @dealer.bust?
    end
    win_payout(outcome)
    win_message(outcome)
  end
  
  def pl_high?
    @player.hand_total > @dealer.hand_total
  end
  
  def push?
    (@player.hand_total == @dealer.hand_total) && !( !@player.blackjack? && @dealer.blackjack? )
  end
  
  def outcome
    if (pl_high? || @dealer.bust?) && !@player.bust?
      outcome = :player
    elsif @player.blackjack? && !@dealer.blackjack?
      outcome = :blackjack
      @player.qualities << "lucky"
    elsif push?
      outcome = :push
    else
      outcome = :dealer
    end
    outcome
  end
  
  def win_payout(symbol)
    p = {player: (@bet * 2),
         blackjack: (@bet * 2.5).round,
         push: @bet,
         dealer: 0}[symbol]
    @printer << "#{p} Chips for #{@player.gender}. #{@player.name}" if p != 0
    @player.chips += p
  end
  
  def win_message(symbol)
    m = {player: "You win!",
         blackjack: "Dealer can't beat that BlackJack. Nice playing.",
         push: "Push.",
         dealer: "Dealer wins."}[symbol]
    @printer << m
  end
  
  def chat
    if @action == :bet
      @printer << "The game is BlackJack, minimum bid is 5 chips."
      @printer << "Place your bets."
    elsif @action == :choice
      @printer << "Make your call."
    elsif @action == :end
      @printer << "Congratulations!" if outcome == :player
      @printer << "That's the way it goes." if @player.bust?
    end 
  end
  
  def deal_player
    #@printer << "'One card for #{@player.gender}. #{@player.qualities.sample}...'"
    @printer << "Dealer deals you a #{@dealer.deal1(@player).to_s}"
  end
  
  def deal_dealer
    @printer << "Dealer draws a #{@dealer.deal1(@dealer).to_s}"
  end
  
  def pl_total
    @printer << "You have #{@player.hand_total}" if !@player.blackjack?
    @printer << "You bust." if @player.bust?
    @printer << "BlackJack!" if @player.blackjack?
  end
  
  def de_total
    @printer << "Dealer has #{@dealer.hand_total}" if !@dealer.blackjack?
    @printer << "Dealer busts!" if @dealer.bust?
    @printer << "Dealer has BlackJack." if @dealer.blackjack?
  end
  
  def test_hand
    @shoe = Shoe.new
    hand =[]
    9.times { hand << @shoe.deal.to_s}
    hand
  end
  
  def unicode(card)
    suit, num = suit_num(card)
    suit_code = {"\u2660"=>"A",
                 "\u2665"=>"B",
                 "\u2666"=>"C",
                 "\u2663"=>"D"}[suit]
    if num.to_i == 0 || num.to_i == 10
      num_code = {"A"  =>"1",
                  "10" =>"A",
                  "J"  =>"B",
                  "Q"  =>"D",
                  "K"  =>"E"}[num]
    else num_code = num
    end
    "&#x1F0" + suit_code + num_code
  end

  def suit_num(card)
    suit = card.to_s.split(//).first
    num  = card.to_s.delete(suit)
    return suit, num
  end

  def color(card)
    suit, num = suit_num(card)
    suit == "\u2665" || suit == "\u2666" ? "red" : "black"
  end
  
  def verify?(username,password)
    sql_str = "SELECT * FROM Users WHERE username = '#{username}' AND password = '#{password}'"
    DATABASE.execute(sql_str)[0] != nil
  end
  
  def load(username)
    sql_str = "SELECT * FROM Users WHERE username = '#{username}'"
    DATABASE.execute(sql_str)[0]
  end
  
  def insert_user(hash)
    key_str = hash.keys.join(", ")
    val_arr = []
    hash.values.each do |value|
      v = value
      v = "'" + value + "'" if value.is_a?(String)
      val_arr << v
    end
    val_str = val_arr.join(", ")
    sql_str = "INSERT INTO Users (#{key_str}) VALUES (#{val_str})"
    DATABASE.execute(sql_str)
    hash
  end

end
