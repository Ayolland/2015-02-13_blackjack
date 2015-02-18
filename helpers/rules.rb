module BlackJackRules
  
  def new_game
    @printer = []
    @action = :bet
    @dealer.hand = []
    @player.hand = []
    @bet = 0
    chat
  end
  
  def first_deal
    @printer = []
    deal_dealer
    de_total
    2.times {deal_player}
    pl_total
    if @player.bust? || @player.hand_total == 21
      @action = :end
      run_dealer
    else
      @action = :choice
    end
    chat
  end
  
  def hit
    @printer = []
    @printer << "You Hit."
    deal_player
    pl_total
    if @player.bust? || @player.hand_total == 21
      @action = :end
      run_dealer
    else
      @action = :choice
    end
    chat
  end
  
  def stand
    @printer = []
    @printer << "You Stand."
    pl_total
    @action = :end
    run_dealer
    chat
  end
  
  def double
    @printer = []
    @printer << "You double your bet and take one more card."
    @player.chips -= @bet
    @bet += @bet
    deal_player
    pl_total
    @action = :end
    run_dealer
    chat
  end
  
  def run_dealer
    loop do
      deal_dealer
      de_total
      break if @dealer.hand_total >=17 || @dealer.bust?
    end
    win_payout(outcome)
    win_message(outcome)
  end
  
  def pl_high?
    @player.hand_total > @dealer.hand_total
  end
  
  def push?
    (@player.hand_total == @dealer.hand_total) && !( !@player.blackjack? && @dealer.blackjack? )
  end
  
  def outcome
    if (pl_high? || @dealer.bust?) && !@player.bust?
      outcome = :player
    elsif @player.blackjack? && !@dealer.blackjack?
      outcome = :blackjack
      @player.qualities << "lucky"
    elsif push?
      outcome = :push
    else
      outcome = :dealer
    end
    outcome
  end
  
  def win_payout(symbol)
    p = {player: (@bet * 2),
         blackjack: (@bet * 2.5).round,
         push: @bet,
         dealer: 0}[symbol]
    @printer << "#{p} Chips for #{@player.gender}. #{@player.name}" if p != 0
    @player.chips += p
  end
  
  def win_message(symbol)
    m = {player: "You win!",
         blackjack: "Dealer can't beat that BlackJack. Nice playing.",
         push: "Push.",
         dealer: "Dealer wins."}[symbol]
    @printer << m
  end
  
  def deal_player
    @printer << "Dealer deals you a #{@dealer.deal1(@player).to_s}"
  end
  
  def deal_dealer
    @printer << "Dealer draws a #{@dealer.deal1(@dealer).to_s}"
  end
  
  def pl_total
    @printer << "You have #{@player.hand_total}" if !@player.blackjack?
    @printer << "You bust." if @player.bust?
    @printer << "BlackJack!" if @player.blackjack?
  end
  
  def de_total
    @printer << "Dealer has #{@dealer.hand_total}" if !@dealer.blackjack?
    @printer << "Dealer busts!" if @dealer.bust?
    @printer << "Dealer has BlackJack." if @dealer.blackjack?
  end
  
end