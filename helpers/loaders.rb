module LoadSaveGamePlayers
  
  def no_input?
    params[:username] == "" ||
    params[:password] == "" ||
    params[:re_enter] == "" ||
    params[:name] == "" ||
    params[:gender] == ""
  end
  
  def load_pl_de
    flush
    #load_qualities
    session[:dealer] = Dealer.new({})
    session[:player] = Player.load(session[:username])
    session[:player].make_rich if session[:player].chips > 2000
  end
  
  def load_qualities
    sql_str = "SELECT * FROM Qualities"
    session[:qualities] = DATABASE.execute(sql_str).each_with_object({}){
      |entry, hash| hash[entry["id"]] = entry["name"]}
  end
  
  def flush
    a = DATABASE.execute("SELECT COUNT (id) FROM UserQualities") #debug purposes
    DATABASE.execute("DELETE FROM UserQualities WHERE date < #{Time.now.to_i - 100}")
    b = DATABASE.execute("SELECT COUNT (id) FROM UserQualities") #debug purposes
    puts "FLUSHED #{a[0][0]-b[0][0]} of #{a[0][0]} USER QUALITIES" #debug purposes
    
  end
 
  # save_game_state
  # Clears the Dealer/Player tables, reloads them with each's hand. Also saves
  # the current bet and the users total chips.
  #
  # Returns:
  # nil
  #
  # State Changes:
  # modifies the database as mentioned above.
  
  #TODO- make this save player qualities.
  
  #def save_game_state
  #  #DATABASE.execute('DELETE FROM Dealer')
  #  #DATABASE.execute('DELETE FROM Player')
  #  #DATABASE.execute('DELETE FROM Bet')
  #  #session[:dealer].hand.each do |card|
  #  #  DATABASE.execute("INSERT INTO Dealer (card) VALUES ('#{card.to_s}')")
  #  #end
  #  #session[:player].hand.each do |card|
  #  #  DATABASE.execute("INSERT INTO Player (card) VALUES ('#{card.to_s}')")
  #  #end
  #  #DATABASE.execute ("INSERT INTO Bet (bet) VALUES (#{session[:bet]})")
  #  DATABASE.execute ("UPDATE Users SET chips=#{session[:player].chips} WHERE username = '#{session[:username]}'")
  #  session[:player].qualities.each do |string|
  #    quality_id = session[:qualities].invert[string]
  #    user_id = session[:player].id
  #    date = Time.now.to_i
  #    DATABASE.execute ("INSERT INTO UserQualities (quality_id,user_id,date) VALUES (#{quality_id},#{user_id},#{date})")
  #  end
  #end
  
  # verify?
  # checks to see if a username exists that matches the supplied password.
  #
  # Returns:
  # Boolean
  
  #def verify?(username,password)
  #  sql_str = "SELECT * FROM Users WHERE username = '#{username}' AND password = '#{password}'"
  #  DATABASE.execute(sql_str)[0] != nil
  #end
  
  # load
  # Pulls a user from the database by username.
  #
  # Parameters:
  # username - username value from database
  #
  # Returns:
  # Hash - options hash which can be used to initiate player object.
  
  #def load(username)
  #  sql_str = "SELECT * FROM Users WHERE username = '#{username}'"
  #  options = DATABASE.execute(sql_str)[0]
  #  sql_str = "SELECT quality_id FROM UserQualities WHERE user_id = #{options["id"]}"
  #  options["qualities"] = []
  #  DATABASE.execute(sql_str).each do |hash|
  #    options["qualities"] << session[:qualities][hash[0]]
  #  end
  #  options
  #end
  
  # insert_hash
  # Adds a user entry into database using a hash of attributes.
  #
  # Parameters:
  # hash - options hash with player attributes
  #
  # Returns:
  # Hash - same hash entered in.
  
  #def insert_user(hash)
  #  hash = hash.reject{|key,value| key == "re_enter"}
  #  key_str = hash.keys.join(", ")
  #  val_arr = []
  #  hash.values.each do |value|
  #    v = value
  #    v = "'" + value + "'" if value.is_a?(String)
  #    val_arr << v
  #  end
  #  val_str = val_arr.join(", ")
  #  sql_str = "INSERT INTO Users (#{key_str}) VALUES (#{val_str})"
  #  DATABASE.execute(sql_str)
  #  hash
  #end
  
end