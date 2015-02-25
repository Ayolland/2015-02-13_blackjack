get "/test" do
  @hand = test_hand
end

get "/style_test" do
  session[:player] = Player.load("cassiegurl")
  session[:player].hand = test_hand
  session[:dealer] = Dealer.new({"hand" => test_hand, "min" => 5})
  @hand = test_hand
  @action = :choice
  session[:bet] = 10
  @printer =["Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."]
  erb :'game/blackjack'
end