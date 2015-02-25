get "/" do
  erb :'users/login'
end

post "/verify" do
  username = params[:username].downcase
  #all usernames are lowercase because forgetfulness
  password = params[:password]
  if Player.verify?(username,password) 
    session[:player] = Player.load(username)
    session[:username] = username
    erb :'users/landing'
  else
    @error = "Sorry, that username and password don't match!"
    erb :'users/login'
  end
end

post "/new_user" do
  erb :'users/new_user'
end

post "/create" do
  params["username"] = params[:username].downcase 
  #all usernames are lowercase because forgetfulness
  params["chips"]    = 500
  #new users are given 500 chips
  exists = Player.load(params["username"]) if !no_input?
  if exists == nil && params["password"] == params["re_enter"] && !no_input?
    session[:player] = Player.new(params)
    session[:player].insert
    session[:username] = params["username"]
    @newuser = true
    erb :'users/landing'
  elsif no_input?
    @error = "Must fill out all the forms."
    erb :'users/new_user'
  elsif exists != nil
    @error = "Sorry, that username is taken already."
    erb :'users/new_user'
  elsif params["password"] != params["re_enter"]
    @error = "Sorry, that password did not match."
    erb :'users/new_user'
  end
end

post "/logout" do
  @error = "Thanks for playing and come back soon!"
  erb :'users/login'
end