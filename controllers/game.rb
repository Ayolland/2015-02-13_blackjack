post "/new_game/:username" do
  load_pl_de
  new_game
  erb :'game/blackjack'
end

post "/first_deal/:username" do
  session[:bet] = params[:bet].to_i
  session[:player].make_reckless if session[:bet] == session[:player].chips
  session[:player].chips -= session[:bet]
  first_deal
  session[:player].save
  erb :'game/blackjack'
end

post "/hit/:username" do
  hit
  session[:player].save
  erb :'game/blackjack'
end

post "/stand/:username" do
  stand
  session[:player].save
  erb :'game/blackjack'
end

post "/double/:username" do
  session[:username] = params[:username]
  double
  session[:player].save
  erb :'game/blackjack'
end