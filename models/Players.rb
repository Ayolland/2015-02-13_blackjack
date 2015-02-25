module LoadPlayer
end

require_relative "hand_ops"

class Player
  attr_reader :name, :username, :id, :gender, :password
  attr_accessor :chips, :qualities, :stop, :hand
  include HandOperations
  extend LoadPlayer
  
  def initialize(options)
    #@hand       = options["hand"]
    @hand       = [] #if !@hand.is_a?(Array)
    @name       = options["name"]
    @gender     = options["gender"]
    @qualities  = options["qualities"]
    @qualities  = [] if !@qualities.is_a?(Array)
    @chips      = options["chips"]
    @stop       = nil
    @username   = options["username"]
    @password   = options["password"]
  end
  
  def self.load(username)
    sql_str = "SELECT * FROM Users WHERE username = '#{username}'"
    options = DATABASE.execute(sql_str)[0]
    if options != nil
      sql_str = "SELECT quality_id FROM UserQualities WHERE user_id = #{options["id"]}"
      options["qualities"] = []
      DATABASE.execute(sql_str).each do |hash|
        sql_str = "SELECT name FROM Qualities WHERE id = '#{hash["quality_id"]}'"
        qual_str = DATABASE.execute(sql_str)[0][0]
        options["qualities"] << qual_str if !options["qualities"].include?(qual_str)
      end
    end
    return nil if options == nil
    puts username.upcase + "LOADED " #debugging
    puts "QUALITIES: " + options["qualities"].join(", ") #debugging
    Player.new(options)
  end
  
  def self.verify?(username,password)
    sql_str = "SELECT * FROM Users WHERE username = '#{username}' AND password = '#{password}'"
    DATABASE.execute(sql_str)[0] != nil
  end
  
  def make_lucky
    self.qualities << "lucky" if !self.qualities.include?("lucky")
  end
  
  def make_unlucky
    self.qualities << "unlucky" if !self.qualities.include?("unlucky")
  end
  
  def make_reckless
    self.qualities << "reckless" if !self.qualities.include?("reckless")
  end
  
  def make_cheap
    self.qualities << "cheap" if !self.qualities.include?("cheap")
  end
  
  def make_broke
    self.qualities << "broke" if !self.qualities.include?("broke")
  end
  
  def make_rich
    self.qualities << "rich" if !self.qualities.include?("rich")
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
  
  def insert
    col_arr = ["gender","name","username","chips","password"]
    val_arr = col_arr.each_with_object([]) do |string,array|
      value = self.send(string)
      array << value if value.is_a?(Integer)
      array << "'" + value + "'" if value.is_a?(String)
    end
    col_str = col_arr.join(", ")
    val_str = val_arr.join(", ")
    sql_str = "INSERT INTO Users (#{col_str}) VALUES (#{val_str})"
    DATABASE.execute(sql_str)
    hash
  end

  def save
    sql_str = "UPDATE Users SET chips=#{self.chips} WHERE username='#{self.username}'"
    DATABASE.execute(sql_str)
    sql_str = "SELECT id FROM Users WHERE username = '#{self.username}'"
    user_id = DATABASE.execute(sql_str)[0]["id"]
    self.qualities.each do |string|
      sql_str = "SELECT id FROM Qualities WHERE name = '#{string}'"
      quality_id = DATABASE.execute(sql_str)[0]["id"]
      date = Time.new.to_i
      sql_str = "INSERT INTO UserQualities (user_id, quality_id, date) VALUES (#{user_id},#{quality_id},#{date})"
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