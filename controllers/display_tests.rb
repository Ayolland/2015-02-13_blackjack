get "/test" do
  @hand = test_hand
  erb :'tests/test'
end

get "/style_test/:switch" do
  @error = "THIS IS A TEST ERROR"
  session[:player] = Player.load("cassiegurl")
  session[:player].hand = test_hand
  session[:dealer] = Dealer.new({"hand" => test_hand, "min" => 5})
  session[:switch]= params[:switch]
  @hand = test_hand
  @action = :choice
  session[:bet] = 10
  @printer =["Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
  erb :'game/blackjack'
end

get "/style_test" do
  redirect "/style_test/blank"
  session[:switch] = params[:switch]
end

get "/mobile_test/:switch" do
  session[:player] = Player.load("cassiegurl")
  session[:player].hand = test_hand
  session[:dealer] = Dealer.new({"hand" => test_hand, "min" => 5})
  session[:switch] = params[:switch]
  @hand = test_hand
  @action = :choice
  session[:bet] = 10
  @printer = ["Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
  erb :'game/blackjack' , :layout => :'/layouts/layout2'
end

get "/mobile_test" do
  redirect "/mobile_test/blank"
end