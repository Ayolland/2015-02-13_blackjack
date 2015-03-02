post "/new_game" do
  load_pl_de
  new_game
  erb :'game/blackjack'
end

post "/first_deal" do
  session[:bet] = params[:bet].to_i
  session[:player].make_reckless if session[:bet] == session[:player].chips
  session[:player].chips -= session[:bet]
  first_deal
  session[:player].save
  erb :'game/blackjack'
end

post "/hit" do
  hit
  session[:player].save
  erb :'game/blackjack'
end

post "/stand" do
  stand
  session[:player].save
  erb :'game/blackjack'
end

post "/double" do
  double
  session[:player].save
  erb :'game/blackjack'
end