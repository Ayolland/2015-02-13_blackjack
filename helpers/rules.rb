module BlackJackRules
  
  # new_game
  # initiates a new blackjack game.
  #
  # Returns:
  # nil
  #
  # State changes:
  # Clears player/dealers hands and the bet.
  
  def new_game
    @printer = []
    @action = :bet
    @dealer.hand = []
    @player.hand = []
    @bet = 0
    chat
  end
  
  # first_deal
  # deals out the first hand.
  #
  # Returns:
  # nil
  #
  # State changes:
  # deals 2 cards to the player, one to the dealer, checks for blackjack.
  
  def first_deal
    @printer = []
    deal_dealer
    de_total
    2.times {deal_player}
    pl_total
    if @player.hand_total == 21
      @action = :end
      run_dealer
    else
      @action = :choice
    end
    chat
  end
  
  # hit
  # Player hits
  #
  # Returns:
  # nil
  #
  # State changes:
  # Deals a card to the player, checks for bust or 21, runs the dealer
  
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
  
  # stand
  # Player stand
  #
  # Returns:
  # nil
  #
  # State changes:
  # runs dealer and ends game.
  
  def stand
    @printer = []
    @printer << "You Stand."
    pl_total
    @action = :end
    run_dealer
    chat
  end
  
  # double
  # Player doubles down
  #
  # Returns:
  # nil
  #
  # State changes:
  # Doubles the bet, deals one card to play, and runs the dealer
  
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
  
  # run_dealer
  # Dealer plays its hand.
  #
  # Returns:
  # nil
  #
  # State changes:
  # deals cards until dealer has equal or more than 17.
  
  def run_dealer
    loop do
      deal_dealer
      de_total
      break if @dealer.hand_total >=17
    end
    win_payout(outcome)
    win_message(outcome)
  end
  
  # pl_high?
  # determines if the player has a higher hand value than the dealer.
  #
  # Returns:
  # Boolean
  
  def pl_high?
    @player.hand_total > @dealer.hand_total
  end
  
  # push?
  # determines if the there is a push.
  #
  # Returns:
  # Boolean
  
  def push?
    (@player.hand_total == @dealer.hand_total) && !( !@player.blackjack? && @dealer.blackjack? )
  end
  
  # outcome
  # determines the winner of the hand.
  #
  # Returns:
  # Symbol
  
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
  
  # win_payout
  # determines how much, if any, the player has won.
  #
  # Parameters:
  # symbol - outcome symbol.
  #
  # Returns:
  # nil
  #
  # State changes:
  # pays player, and adds a message to the printer
  
  def win_payout(symbol)
    p = {player: (@bet * 2),
         blackjack: (@bet * 2.5).round,
         push: @bet,
         dealer: 0}[symbol]
    @printer << "#{p} Chips for #{@player.gender}. #{@player.name}" if p != 0
    @player.chips += p
    nil
  end
  
  # win_message
  # adds a message describing the win.
  #
  # Parameters:
  # symbol - outcome symbol.
  #
  # Returns:
  # nil
  #
  # State changes:
  # Adds a message to the printer
  
  def win_message(symbol)
    m = {player: "You win!",
         blackjack: "Dealer can't beat that BlackJack. Nice playing.",
         push: "Push.",
         dealer: "Dealer wins."}[symbol]
    @printer << m
    nil
  end
  
  # deal_player
  # Deals a card to the player
  #
  # Returns:
  # nil
  #
  # State changes:
  # Deals a card to the player and adds a message to the printer
  
  def deal_player
    @printer << "Dealer deals you a #{@dealer.deal1(@player).to_s}"
    nil
  end
  
  # deal_dealer
  # Deals a card to the player
  #
  # Returns:
  # nil
  #
  # State changes:
  # Deals a card to the player and adds a message to the printer
  
  def deal_dealer
    @printer << "Dealer draws a #{@dealer.deal1(@dealer).to_s}"
    nil
  end
  
  # pl_total
  # Displays a message about the players total.
  #
  # Returns:
  # nil
  #
  # State changes:
  # adds a message to the printer
  
  def pl_total
    @printer << "You have #{@player.hand_total}" if !@player.blackjack?
    @printer << "You bust." if @player.bust?
    @printer << "BlackJack!" if @player.blackjack?
    nil
  end
  
  # pl_total
  # Displays a message about the players total.
  #
  # Returns:
  # nil
  #
  # State changes:
  # adds a message to the printer
  
  def de_total
    @printer << "Dealer has #{@dealer.hand_total}" if !@dealer.blackjack?
    @printer << "Dealer busts!" if @dealer.bust?
    @printer << "Dealer has BlackJack." if @dealer.blackjack?
    nil
  end
  
end