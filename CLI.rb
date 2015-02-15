require 'pry'
require 'sqlite3'
require 'card_deck'
include CardDeck
require_relative 'shoe'
require_relative 'card_values'
require_relative 'players'

DATABASE = SQLite3::Database.new('database/database.db')
require_relative "database/database_setup.rb"

class Driver
  
  def initialize
    @player = Player.new(self.intro)
    
    @dealer = Dealer.new({:min => 5})
    puts "Let's play BlackJack!"
    puts "No Hole card, 5 chip minimum bid."
    puts "You have #{@player.chips} chips."
    self.run
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
    sql_str = "SELECT * FROM Users WHERE username = '#{username}' AND password = '#{password}'"
    player = DATABASE.execute(sql_str)[0]
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
    @dealer.hand = []
    @player.hand = []
    @dealer.stop = nil
    @player.stop = nil
  end
  
  def place_bet
    puts "Place your bet."
    loop do
      puts "(Enter how many chips you want to wager on this hand.)"
      @bet = gets.to_i
      
      break if @bet <= @player.chips
      puts "You don't have that many chips!"
    end
    @bet = @dealer.min if @bet < @dealer.min
    @player.chips -= @bet
    puts "You bid #{@bet} chips."
  end
  
  def deal_player
    more_cards
    puts "Dealer deals you a #{@dealer.deal1(@player).to_s}"
  end
  
  def deal_dealer
    more_cards
    puts "Dealer draws a #{@dealer.deal1(@dealer).to_s}"
  end
  
  def more_cards
    if @dealer.shoe.cards == []
      puts "Getting a new shoe of cards..."
      @dealer.new_shoe
    end
  end
  
  def pl_total
    puts "You have #{@player.hand_total}" if !@player.blackjack?
    puts "BlackJack!" if @player.blackjack?
  end
  
  def de_total
    puts "Dealer has #{@dealer.hand_total}"
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
      if @dealer.bust?
        puts "Dealer busts!"
        @dealer.stop = :bust
      elsif @dealer.blackjack?
        puts "Dealer has BlackJack."
        @dealer.stop = :bjack
      elsif @dealer.hand_total > 17
        puts "Dealer stands."
        @dealer.stop = :stand
      end
      break if @dealer.stop != nil
    end
  end
  
  def hit
    puts "You hit."
    self.deal_player
    self.pl_total
    if @player.bust?
      puts "You bust!"
      @player.stop = :bust
    end
  end
  
  def stand
    puts "You stand."
    @player.stop = :stand
  end
  
  def double
    puts "You double your bet, and take one more card."
    @player.chips -= @bet
    @bet = (@bet * 2)
    @player.stop = :stand
    self.deal_player
    self.pl_total
    if @player.bust?
      puts "You bust!"
      @player.stop = :bust
    end
  end
  
  def pl_high?
    @player.hand_total > @dealer.hand_total
  end
  
  def push?
    (@player.hand_total == @dealer.hand_total) && !( !@player.blackjack? && @dealer.blackjack? )
  end
  
  def outcome
    if (@player.stop == :stand && pl_high?) || (@dealer.bust? && !@player.bust?)
      outcome = :player
    elsif @player.blackjack? && !@dealer.blackjack?
      outcome = :blackjack
    elsif push?
      outcome = :push
    else
      outcome = :dealer
    end
  end
  
  def pl_win
    puts "You win!"
    @winnings = (@bet + @bet)
  end
  
  def pl_bj
    puts "Dealer can't beat #{@player.name}'s BlackJack. Great job."
    @player.chips += (@bet + (@bet * 1.5).round)
  end
  
  def push
    puts "Push."
    @player.chips += @bet
  end
  
  def run_game
    reset
    place_bet
    self.deal_dealer
    self.de_total
    2.times do
      deal_player
    end
    self.pl_total
    loop do
      self.pl_choice
      break if @player.stop != nil
    end
    dl_choice
    if (@player.stop == :stand && pl_high?) || (@dealer.bust? && !@player.bust?)
      self.pl_win
    elsif @player.blackjack? && !@dealer.blackjack?
      self.pl_bj
    elsif push?
      self.push
    else
      puts "Dealer wins."
    end
  end
  
  def run
    loop do
      input = nil
      self.run_game
      puts "You have #{@player.chips}"
      puts "(Enter 1 to leave the table, anything else to play again.)"
      input = gets.to_i
      break if input == 1
    end
    @player.save
    puts "You ended with #{@player.chips} chips."
  end

end

Driver.new