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

set :bind, '0.0.0.0'
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
  if Player.verify?(username,password) 
    session[:player] = Player.load(username)
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
  params["username"] = params[:username].downcase 
  #all usernames are lowercase because forgetfulness
  params["chips"]    = 500
  #new users are given 500 chips
  exists = Player.load(params["username"]) if !no_input?
  if exists == nil && params["password"] == params["re_enter"] && !no_input?
    session[:player] = Player.new(params)
    session[:player].insert
    session[:username] = params["username"]
    @newuser = true
    erb :landing
  elsif no_input?
    @error = "Must fill out all the forms."
    erb :new_user
  elsif exists != nil
    @error = "Sorry, that username is taken already."
    erb :new_user
  elsif params["password"] != params["re_enter"]
    @error = "Sorry, that password did not match."
    erb :new_user
  end
end

get "/style_test" do
  session[:player] = Player.load("cassiegurl")
  session[:player].hand = test_hand
  session[:dealer] = Dealer.new({"hand" => test_hand, "min" => 5})
  @hand = test_hand
  @action = :choice
  session[:bet] = 10
  @printer =["Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
  erb :blackjack
end

post "/new_game/:username" do
  load_pl_de
  new_game
  erb :blackjack
end

post "/first_deal/:username" do
  session[:bet] = params[:bet].to_i
  session[:player].make_reckless if session[:bet] == session[:player].chips
  session[:player].chips -= session[:bet]
  first_deal
  session[:player].save
  erb :blackjack
end

post "/hit/:username" do
  hit
  session[:player].save
  erb :blackjack
end

post "/stand/:username" do
  stand
  session[:player].save
  erb :blackjack
end

post "/double/:username" do
  session[:username] = params[:username]
  double
  session[:player].save
  erb :blackjack
end

post "/logout" do
  @error = "Thanks for playing and come back soon!"
  erb :login
end

helpers LoadSaveGamePlayers, BlackJackRules, CardOperations, DealerBanter