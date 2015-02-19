module DealerBanter

  def chat
    if @action == :bet
      @printer << "The game is BlackJack, minimum bid is 5 chips."
      @printer << "Place your bets."
    elsif @action == :choice
      @printer << "Make your call, #{session[:player].petname}."
    elsif @action == :end
      @printer << "Congratulations, #{session[:player].petname}!" if outcome == :player
      @printer << "That's the way it goes, #{session[:player].petname}." if session[:player].bust?
    end 
    if session[:player].qualities.include?("unlucky") && session[:player].bust?
      @printer << "Not having the best day, are ya?" 
    end
    if session[:player].qualities.include?("lucky") && session[:player].blackjack?
      @printer << "You're on fire!" 
    end
    if session[:player].chips == 0 && @action == :end && (outcome == :player || outcome == :blackjack)
      @printer << "Somebody upstairs must like you." 
    end
    if session[:player].qualities.include?("rich") && @action == :end && (outcome == :dealer) && session[:bet] < (session[:player].chips) / 2
      @printer << "You can afford it." 
    end
    if session[:player].chips == 0 && @action == :end && (outcome == :dealer)
      @printer << "Well, that about does it for you." 
    end
  end

  
end