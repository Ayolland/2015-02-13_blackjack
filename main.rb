require 'pry'
require 'sinatra'
require 'sqlite3'
require 'card_deck'
include CardDeck
require_relative 'models/shoe'
require_relative 'models/card_values'
require_relative 'models/players'
require_relative 'helpers/loaders'
require_relative 'helpers/rules'
require_relative 'helpers/banter'
require_relative 'helpers/cards'

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

helpers LoadSaveGamePlayers, BlackJackRules, CardOperations, DealerBanter