module LoadSaveGamePlayers
  
  #commenting this out becasue I believe this method is abandoned.... (correction, it's not...) #TODO refactor this crap...
  
  def load_pl_de
    session[:dealer] = Dealer.new({})
    session[:player] = Player.new(load(session[:username]))
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
  
  def save_game_state
    DATABASE.execute('DELETE FROM Dealer')
    DATABASE.execute('DELETE FROM Player')
    DATABASE.execute('DELETE FROM Bet')
    session[:dealer].hand.each do |card|
      DATABASE.execute("INSERT INTO Dealer (card) VALUES ('#{card.to_s}')")
    end
    session[:player].hand.each do |card|
      DATABASE.execute("INSERT INTO Player (card) VALUES ('#{card.to_s}')")
    end
    DATABASE.execute ("INSERT INTO Bet (bet) VALUES (#{session[:bet]})")
    DATABASE.execute ("UPDATE Users SET chips=#{session[:player].chips} WHERE username = '#{session[:username]}'")    
  end
  
  # load_game_state
  # Loads the player's and dealer's hands as well as the current bet.
  #
  # Returns:
  # dealer - Array of card-strings
  # player - Array of card-strings
  # bet - Integer
  
  def load_game_state
    temp = DATABASE.execute('SELECT * FROM Dealer')
    dealer = temp.each_with_object([]){|hash,array| array << hash[1]}
    temp = DATABASE.execute('SELECT * FROM Player')
    player = temp.each_with_object([]){|hash,array| array << hash[1]}
    temp = DATABASE.execute('SELECT * FROM Bet')
    bet = temp[0][1]
    return dealer, player, bet
  end
  
  # verify?
  # checks to see if a username exists that matches the supplied password.
  #
  # Returns:
  # Boolean
  
  def verify?(username,password)
    sql_str = "SELECT * FROM Users WHERE username = '#{username}' AND password = '#{password}'"
    DATABASE.execute(sql_str)[0] != nil
  end
  
  # load
  # Pulls a user from the database by username.
  #
  # Parameters:
  # username - username value from database
  #
  # Returns:
  # Hash - options hash which can be used to initiate player object.
  
  def load(username)
    sql_str = "SELECT * FROM Users WHERE username = '#{username}'"
    DATABASE.execute(sql_str)[0]
  end
  
  # insert_hash
  # Adds a user entry into database using a hash of attributes.
  #
  # Parameters:
  # hash - options hash with player attributes
  #
  # Returns:
  # Hash - same hash entered in.
  
  def insert_user(hash)
    key_str = hash.keys.join(", ")
    val_arr = []
    hash.values.each do |value|
      v = value
      v = "'" + value + "'" if value.is_a?(String)
      val_arr << v
    end
    val_str = val_arr.join(", ")
    sql_str = "INSERT INTO Users (#{key_str}) VALUES (#{val_str})"
    DATABASE.execute(sql_str)
    hash
  end
  
end