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

enable :sessions

get "/test" do
  @hand = test_hand
end

get "/" do
  erb :login
end

post "/verify" do
  username = params[:username].downcase
  password = params[:password]
  if verify?(username,password) 
    session[:player] = Player.new(load(username))
    session[:username] = username
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
  hash["username"] = params[:username].downcase
  hash["password"] = params[:password]
  hash["re_enter"] = params[:re_enter]
  hash["name"]     = params[:name]
  hash["gender"]   = params[:gender]
  hash["chips"]    = 500
  exists = load(hash["username"])
  if exists == nil && hash["password"] == hash["re_enter"]
    insert_user(hash)
    session[:player] = Player.new(load(hash["username"]))
    session[:username] = hash["username"]
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
  session[:player] = Player.new(hash)
  session[:dealer] = Dealer.new({"hand" => test_hand, "min" => 5})
  @hand = test_hand
  @action = :choice
  session[:bet] = 10
  @printer =["Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
  erb :test
  erb :blackjack
end

post "/new_game/:username" do
  session[:username] = params[:username]
  load_pl_de
  new_game
  erb :blackjack
end

post "/first_deal/:username" do
  session[:username] = params[:username]
  session[:bet] = params[:bet].to_i
  load_pl_de
  session[:player].chips -= session[:bet]
  first_deal
  save_game_state
  erb :blackjack
end

post "/hit/:username" do
  session[:username] = params[:username]
  load_pl_de
  session[:dealer].hand, session[:player].hand, session[:bet] = load_game_state
  hit
  save_game_state
  erb :blackjack
end

post "/stand/:username" do
  session[:username] = params[:username]
  load_pl_de
  session[:dealer].hand, session[:player].hand, session[:bet] = load_game_state
  stand
  save_game_state
  erb :blackjack
end

post "/double/:username" do
  session[:username] = params[:username]
  load_pl_de
  session[:dealer].hand, session[:player].hand, session[:bet] = load_game_state
  double
  save_game_state
  erb :blackjack
end

post "/logout" do
  @error = "Thanks for playing and come back soon!"
  erb :login
end

helpers LoadSaveGamePlayers, BlackJackRules, CardOperations, DealerBanter