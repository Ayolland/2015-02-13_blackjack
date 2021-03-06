require 'pry'
require 'sqlite3'
require 'card_deck'
include CardDeck
require_relative 'shoe'
require_relative 'card_values'
require_relative 'players'

DATABASE = SQLite3::Database.new('../database/database.db')
require_relative "../database/database_setup.rb"

class Driver
  
  def initialize
    session[:player] = Player.new(self.intro)
    session[:dealer] = Dealer.new({:min => 5})
    load_qualities if session[:player].id != nil
    
    @printer = []
    @printer << "Let's play BlackJack!"
    @printer << "No Hole card, 5 chip minimum bid."
    @printer << "You have #{session[:player].chips} chips."
    printy
    self.run
  end
  
  def load_qualities
    array = DATABASE.execute("SELECT * FROM Qualities")
    quals = array.each_with_object({}){|entry,hash| hash[entry["id"]] = entry["name"]}
    join_tbl = DATABASE.execute("SELECT quality_id FROM UserQualities WHERE user_id = #{session[:player].id}")
    join_tbl.each {|entry| session[:player].qualities << quals[entry["quality_id"]]}
  end
  
  def printy
    @printer.each {|string| puts string}
    @printer = []
  end
  
  def intro
    puts "Welcome!"
    puts "1. LOGIN with existing username"
    puts "2. CREATE a new username"
    input = 0
    loop do
      puts "Please choose a valid selection."
      input = gets.to_i
      break if input > 0 && input < 3
    end
    self.send(["login","new_user"][input - 1])
  end
  
  def login
    puts "LOGIN:"
    puts "Enter username:"
    username = gets.chomp
    puts "Enter password:"
    password = gets.chomp
    player = load_player_as_hash(username,password)
    if player == nil
      puts "Username and password did not match."
      puts "(Enter 1 to try again and anything else to create a new user)"
      input = gets.to_i
      input == 1 ? login : new_user
    end
    puts "Welcome back #{player["gender"]}. #{player["name"]}."
    player
  end
  
  def new_user
    puts "NEW USERNAME:"
    username = nil
    loop do
      puts "Please choose a unique username:"
      username = gets.chomp
      sql_str = "SELECT * FROM Users WHERE username = '#{username}'"
      
      break if DATABASE.execute(sql_str) == []
      puts "Sorry, that username is already taken."
    end
    password = ""
    loop do
      puts "Please choose a password:"
      password = gets.chomp
      puts "Enter password one more time:"
      dbl_check = gets.chomp
      break if (dbl_check == password && password.length > 5)
      puts "Password does not match..." if password != dbl_check
      puts "Password must be 6+ characters..." if password.length <= 5 
    end
    puts "Please enter your name:"
    name = gets.chomp.capitalize
    input = 0
    loop do
      puts "Please select your gender:"
      puts "1: Male"
      puts "2: Female"
      puts "3: Neutral"
      input = gets.to_i
      break if input > 0 && input < 4
      "Sorry, one more time."
    end
    gender = ["Mr","Ms","Mx"][input - 1]
    options = {name: name, username: username, password: password, gender: gender, chips: 500}
    puts "Is this correct?"
    puts
    puts "Username: #{username}"
    puts "Password: " + ("*" * password.length)
    puts "Name: #{gender}. #{name}"
    puts "(Enter 1 to accept, anything else to redo.)"
    input = gets.to_i
    input == 1 ? insert_user(options) : new_user
  end
  
  def load_player_as_hash(username,password)
    sql_str = "SELECT * FROM Users WHERE username = '#{username}' AND password = '#{password}'"
    player = DATABASE.execute(sql_str)[0]
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
  
  def reset
    session[:dealer].hand = []
    session[:player].hand = []
    session[:dealer].stop = nil
    session[:player].stop = nil
  end
  
  def place_bet
    puts "Place your bet."
    loop do
      puts "(Enter how many chips you want to wager on this hand.)"
      session[:bet] = gets.to_i
      
      break if session[:bet] <= session[:player].chips
      puts "You don't have that many chips!"
    end
    if session[:bet] < session[:dealer].min
      session[:bet] = session[:dealer].min 
      session[:player].qualities << "cheap"
      @printer << "It's a minimum bid of #{session[:dealer].min}."
    end
    session[:player].chips -= session[:bet]
    @printer << "You bid #{session[:bet]} chips."
    printy
  end
  
  def deal_player
    more_cards
    #@printer << "'One card for #{session[:player].gender}. #{session[:player].qualities.sample}...'"
    @printer << "Dealer deals you a #{session[:dealer].deal1(session[:player]).to_s}"
  end
  
  def deal_dealer
    more_cards
    @printer << "Dealer draws a #{session[:dealer].deal1(session[:dealer]).to_s}"
  end
  
  def more_cards
    if session[:dealer].shoe.cards == []
      @printer << "Getting a new shoe of cards..."
      session[:dealer].new_shoe
    end
  end
  
  def pl_total
    @printer << "You have #{session[:player].hand_total}" if !session[:player].blackjack?
    @printer << "BlackJack!" if session[:player].blackjack?
  end
  
  def de_total
    @printer << "Dealer has #{session[:dealer].hand_total}"
  end
  
  def pl_choice
    puts "(Enter your decision.)"
    puts "1: HIT"
    puts "2: STAND"
    puts "3: DOUBLE DOWN"
    input = gets.to_i
    input = 1 if input < 1 || input > 3
    send(["hit","stand","double"][input - 1])
  end
  
  def dl_choice
    self.de_total
    loop do
      self.deal_dealer
      self.de_total
      if session[:dealer].bust?
        @printer << "Dealer busts!"
        session[:dealer].stop = :bust
      elsif session[:dealer].blackjack?
        @printer << "Dealer has BlackJack."
        session[:dealer].stop = :bjack
      elsif session[:dealer].hand_total > 17
        @printer << "Dealer stands."
        session[:dealer].stop = :stand
      end
      break if session[:dealer].stop != nil
    end
  end
  
  def hit
    @printer << "You hit."
    self.deal_player
    self.pl_total
    if session[:player].bust?
      @printer << "You bust!"
      session[:player].stop = :bust
    end
  end
  
  def stand
    @printer << "You stand."
    session[:player].stop = :stand
  end
  
  def double
    if session[:player].hand_total > 12
      session[:player].qualities << "reckless"
      @printer << "Whatever you say."
    end
    @printer << "You double your bet, and take one more card."
    session[:player].chips -= session[:bet]
    session[:bet] = (session[:bet] * 2)
    session[:player].stop = :stand
    self.deal_player
    self.pl_total
    if session[:player].bust?
      @printer << "You bust!"
      session[:player].stop = :bust
    end
  end
  
  def pl_high?
    session[:player].hand_total > session[:dealer].hand_total
  end
  
  def push?
    (session[:player].hand_total == session[:dealer].hand_total) && !( !session[:player].blackjack? && session[:dealer].blackjack? )
  end
  
  def outcome
    if (session[:player].stop == :stand && pl_high?) || (session[:dealer].bust? && !session[:player].bust?)
      outcome = :player
    elsif session[:player].blackjack? && !session[:dealer].blackjack?
      outcome = :blackjack
      session[:player].qualities << "lucky"
    elsif push?
      outcome = :push
    else
      outcome = :dealer
    end
    outcome
  end
  
  def payout(symbol)
    p = {player: (session[:bet] * 2),
         blackjack: (session[:bet] * 2.5).round,
         push: session[:bet],
         dealer: 0}[symbol]
    session[:player].chips += p
  end
  
  def message(symbol)
    m = {player: "You win!",
         blackjack: "Dealer can't beat that BlackJack. Nice playing.",
         push: "Push.",
         dealer: "Dealer wins."}[symbol]
    @printer << m
  end
  
  def run_game
    reset
    place_bet
    self.deal_dealer
    self.de_total
    2.times do
      deal_player
    end
    printy
    self.pl_total
    printy
    loop do
      self.pl_choice
      printy
      break if session[:player].stop != nil
    end
    dl_choice
    printy
    payout(outcome)
    message(outcome)
    printy
  end
  
  def run
    loop do
      input = nil
      self.run_game
      puts "You have #{session[:player].chips}"
      puts "(Enter 1 to leave the table, anything else to play again.)"
      input = gets.to_i
      break if input == 1
    end
    session[:player].save
    puts "You ended with #{session[:player].chips} chips."
  end

end

Driver.new