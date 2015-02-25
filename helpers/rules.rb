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
    session[:dealer].hand = []
    session[:player].hand = []
    session[:bet] = 0
    if session[:player].chips <= 0
      @error = "You're bankrupt! The house loans you 200 chips."
      session[:player].chips = 200
      session[:player].qualities = []
      session[:player].make_broke
      @printer << "Playing responsibly, I see."
    end
    if session[:player].qualities.include?("rich")
      @printer << "Always good to have you, #{session[:player].gender}. #{session[:player].name}." 
    end
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
    if session[:player].chips == 0
      @printer << "#{session[:player].gender}. #{session[:player].name} is all in!"
      session[:player].make_reckless
    end 
    deal_dealer
    de_total
    2.times {deal_player}
    pl_total
    if session[:player].hand_total == 21
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
    if session[:player].bust? || session[:player].hand_total == 21
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
    session[:player].make_reckless if session[:player].hand_total > 12
    session[:player].chips -= session[:bet]
    session[:bet] += session[:bet]
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
      break if session[:dealer].hand_total >=17
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
    session[:player].hand_total > session[:dealer].hand_total
  end
  
  # push?
  # determines if the there is a push.
  #
  # Returns:
  # Boolean
  
  def push?
    (session[:player].hand_total == session[:dealer].hand_total) && !( !session[:player].blackjack? && session[:dealer].blackjack? )
  end
  
  # outcome
  # determines the winner of the hand.
  #
  # Returns:
  # Symbol
  
  def outcome
    if (pl_high? || session[:dealer].bust?) && !session[:player].bust?
      outcome = :player
    elsif session[:player].blackjack? && !session[:dealer].blackjack?
      outcome = :blackjack
      session[:player].qualities << "lucky"
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
    p = {player: (session[:bet] * 2),
         blackjack: (session[:bet] * 2.5).round,
         push: session[:bet],
         dealer: 0}[symbol]
    @printer << "#{p} Chips for #{session[:player].gender}. #{session[:player].name}" if p != 0
    session[:player].chips += p
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
    @printer << "Dealer deals you a #{session[:dealer].deal1(session[:player]).to_s}"
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
    @printer << "Dealer draws a #{session[:dealer].deal1(session[:dealer]).to_s}"
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
    @printer << "You have #{session[:player].hand_total}" if !session[:player].blackjack?
    @printer << "You bust." if session[:player].bust?
    if session[:player].blackjack?
      @printer << "BlackJack!" 
      session[:player].make_lucky
    end
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
    @printer << "Dealer has #{session[:dealer].hand_total}" if !session[:dealer].blackjack?
    @printer << "Dealer busts!" if session[:dealer].bust? 
    if session[:dealer].blackjack?
      @printer << "Dealer has BlackJack."
      session[:player].make_unlucky
    end
    nil
  end
  
end