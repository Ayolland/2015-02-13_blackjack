require_relative "hand_ops"

class Player
  attr_reader :name, :username, :id, :gender
  attr_accessor :chips, :qualities, :stop, :hand
  include HandOperations
  
  def initialize(options)
    @hand       = options["hand"]
    @hand       = [] if !@hand.is_a?(Array)
    @name       = options["name"]
    @gender     = options["gender"]
    @qualities  = options["qualities"]
    @qualities  = [] if !@qualities.is_a?(Array)
    @chips      = options["chips"]
    @stop       = nil
    @username   = options["username"]
    @id         = options["id"]
  end

  def save
    sql_str = "UPDATE Users SET chips=#{self.chips} WHERE username='#{self.username}'"
    binding.pry
    DATABASE.execute(sql_str)
    sql_str = "SELECT id FROM Users WHERE username = '#{self.username}'"
    user_id = DATABASE.execute(sql_str)[0]["id"]
    self.qualities.each do |string|
      sql_str = "SELECT id FROM Qualities WHERE name = '#{string}'"
      quality_id = DATABASE.execute(sql_str)[0]["id"]
      sql_str = "INSERT INTO UserQualities (user_id, quality_id) VALUES (#{user_id},#{quality_id})"
      DATABASE.execute(sql_str)
    end
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