module DealerBanter

  def chat
    if @action == :bet
      @printer << "The game is BlackJack, minimum bid is 5 chips."
      @printer << "Place your bets."
    elsif @action == :choice
      @printer << "Make your call."
    elsif @action == :end
      @printer << "Congratulations!" if outcome == :player
      @printer << "That's the way it goes." if @player.bust?
    end 
  end
  
end