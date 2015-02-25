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

require_relative 'controllers/users.rb'
require_relative 'controllers/game.rb'
require_relative 'controllers/display_tests.rb'

helpers LoadSaveGamePlayers, BlackJackRules, CardOperations, DealerBanter