require_relative "hand_ops"

class Player
  attr_reader :name, :username
  attr_accessor :chips, :qualities, :stop, :hand
  include HandOperations
  
  def initialize(options)
    @hand       = options["hand"]
    @hand       = [] if !@hand.is_a?(Array)
    @name       = options["name"]
    @qualities  = options["qualities"]
    @qualities  = [] if !@qualities.is_a?(Array)
    @chips      = options["chips"]
    @stop       = nil
    @username   = options["username"]
  end

  def save
    sql_str = "UPDATE Users SET chips=#{self.chips} WHERE username='#{self.username}'"
    binding.pry
    DATABASE.execute(sql_str)
  end

end

class Dealer
  attr_reader :name, :min, :shoe
  attr_accessor :stop, :hand
  include HandOperations
  
  def initialize(options)
    @hand = options[:hand]
    @hand = [] if !@hand.is_a?(Array)
    @name = "Dealertron5000"
    @min  = options[:min]
    @stop = nil
    self.new_shoe
  end
  
  def new_shoe(size=1)
    @shoe = Shoe.new(1)
  end
  
  def deal1(player)
    card = @shoe.deal
    player.hand << card
    card
  end
  
end