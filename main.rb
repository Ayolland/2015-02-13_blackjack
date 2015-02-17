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
  test_hand
  erb :test
end

get "/" do
  erb :login
end

post "/verify" do
  username = params[:username]
  password = params[:password]
  if verify?(username,password) 
    redirect to("/test") 
  else
    @error = :no_user
    erb :login
  end
end

get "/new_user" do
  erb :new_user
end

post "/create" do
  hash = {}
  hash["username"] = params[:username]
  hash["password"] = params[:password]
  hash["name"]     = params[:name]
  hash["gender"]   = params[:gender]
  hash["chips"]    = 500
  binding.pry
  insert_user(hash)
  redirect to("/test")
end

get "/game/:username" do
  
end

get "/style_test" do
  hash = load("cassiegurl")
  hash["hand"] = test_hand
  @player = Player.new(hash)
  @dealer = Dealer.new({"hand" => test_hand, "min" => 5})
  erb :blackjack
end

helpers do
  
  def test_hand
    @shoe = Shoe.new
    hand =[]
    9.times { hand << @shoe.deal}
    hand
  end
  
  def unicode(card)
    suit_code = {"\u2660"=>"A",
                 "\u2665"=>"B",
                 "\u2666"=>"C",
                 "\u2663"=>"D"}[card.suit]
    if card.num.is_a?(String) || card.num == 10
      num_code = {"Ace"   =>"1",
                  "10"    =>"A",
                  "Jack"  =>"B",
                  "Queen" =>"D",
                  "King"  =>"E"}[card.num.to_s]
    else num_code = card.num.to_s
    end
    "&#x1F0" + suit_code + num_code
  end

  def color(card)
    card.red? ? "red" : "black"
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
