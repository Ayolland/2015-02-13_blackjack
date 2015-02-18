module HandOperations

  # blackjack?
  # Determines if a player has a blackjack.
  #
  # Returns:
  # Boolean

  def blackjack?
    hand_total == 21 && @hand.length == 2
  end
  
  # bust?
  # Determines if a player has bust.
  #
  # Returns:
  # Boolean
  
  def bust?
    hand_total > 21
  end
  
  # hand_total
  # Determines the total of the player's blackjack hand
  #
  # Returns:
  # Integer - total value

  def hand_total
    total = 0
    @hand.each {|card| total += value(card)}
    total_aces.times {total -= 10 if total > 21} if total_aces != 0
    total
  end
  
  # total_aces
  # Determines how many Aces are in a hand.
  #
  # Returns:
  # Integer
  
  def total_aces
    @hand.each_with_object([]){|card,array| array << card if value(card) == 11}.length
  end
  
end