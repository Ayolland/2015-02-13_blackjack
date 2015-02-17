require 'pry'
require 'card_deck'
require 'sqlite3'
include CardDeck
require_relative 'shoe'
require_relative 'card_values'
require_relative 'players'
require_relative 'converter'
DATABASE = SQLite3::Database.new('database/database.db')
require_relative "database/database_setup.rb"

shoe = Shoe.new
dealer = Dealer.new({})
player = Player.new({"name" => "Doug"})
binding.pry