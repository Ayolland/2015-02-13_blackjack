module LoadSaveGamePlayers
  
  # no_input?
  # tests to see if any of the new-user-creation forms were not filled out.
  #
  # Returns: Boolean
  # TODO somehow move this into Player class...
  
  def no_input?
    params[:username] == "" ||
    params[:password] == "" ||
    params[:re_enter] == "" ||
    params[:name] == "" ||
    params[:gender] == ""
  end
  
  # load_pl_de
  # loads the player and dealer objects, may set the player as rich.
  #
  # Returns: nil
  #
  # State Changes:
  # sets :dealer and :player in session, may add to session[:player].qualities.
  # TODO Move this somewhere else...
  
  def load_pl_de
    flush
    session[:dealer] = Dealer.new({})
    session[:player] = Player.load(session[:username])
    session[:player].make_rich if session[:player].chips > 2000
  end

  #flush
  # IS SUPPOSED TO clear out any qualities older than 100 seconds.
  #
  # Returns: nil
  # 
  # State Changes:
  # modifies the UserQualities table in the database
  # TODO 1. fix this mf
  # TODO 2. Move into a Qualities class?
  
  def flush
    t = Time.now.to_i - 100
    sql_str = "DELETE FROM UserQualities WHERE date < #{t}"
    a = DATABASE.execute("SELECT COUNT (id) FROM UserQualities") #debug purposes
    #binding.pry
    DATABASE.execute(sql_str)
    b = DATABASE.execute("SELECT COUNT (id) FROM UserQualities") #debug purposes
    puts "FLUSHED #{a[0][0]-b[0][0]} of #{a[0][0]} USER QUALITIES" #debug
  end
  
end