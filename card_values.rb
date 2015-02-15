# value
# Determines the BlackJack value of a card object. Aces are set to 11.
#
# Parameters:
# card - Card object
#
# Returns:
# Integer - between 2-11

def value(card)
  value = card.num
  if value.is_a?(String)
    value == "Ace" ? value = 11 : value = 10
  end
  value
end
