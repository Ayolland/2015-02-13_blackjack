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
    t = Time.now.to_i - 100
    sql_str = "DELETE FROM UserQualities WHERE date < #{t}"
    a = DATABASE.execute("SELECT COUNT (id) FROM UserQualities") #debug purposes
    #binding.pry
    DATABASE.execute(sql_str)
    b = DATABASE.execute("SELECT COUNT (id) FROM UserQualities") #debug purposes
    puts "FLUSHED #{a[0][0]-b[0][0]} of #{a[0][0]} USER QUALITIES" #debug
  end
  
end