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
  
  def make_lucky
    self.qualities << "lucky"
  end
  
  def make_unlucky
    self.qualities << "unlucky"
  end
  
  def make_reckless
    self.qualities << "reckless"
  end
  
  def make_cheap
    self.qualities << "cheap"
  end
  
  def make_broke
    self.qualities << "broke"
  end
  
  def make_rich
    self.qualities << "rich"
  end
  
  def petname
    names = ["#{@gender}. #{@name}"]
    names.concat(["crazypants", "wild card","oh fearless one","big spender"]) if qualities.include?("reckless")
    names.concat(["#{@gender}. Lucky", "lucky charms"]) if qualities.include?("lucky")
    names.concat(["#{@gender}. Misfortune", "you poor sot"]) if qualities.include?("unlucky")
    names.concat(["Scrooge", "stingy", ""]) if qualities.include?("cheap")
    names.concat(["#{@gender}. Moneybags", "Playa", "Richy Rich"]) if qualities.include?("rich")
    names.concat(["deadbeat", "you mooch", "ya bum"]) if qualities.include?("broke")
    names.sample
  end

  def save
    sql_str = "UPDATE Users SET chips=#{self.chips} WHERE username='#{self.username}'"
    
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
    @hand = options["hand"]
    @hand = [] if !@hand.is_a?(Array)
    @name = "Dealertron5000"
    @min  = 5
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