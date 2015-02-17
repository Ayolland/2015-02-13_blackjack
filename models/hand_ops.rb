module HandOperations

  def blackjack?
    hand_total == 21 && @hand.length == 2
  end
  
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
    @hand.each do |card|
      v = value(card)
      if v != 11
        total += v
      else
        total < 11 ? total += 11 : total += 1
      end
    end
    total
  end
  
end