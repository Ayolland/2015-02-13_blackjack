# value
# Determines the BlackJack value of a card object. Aces are set to 11.
#
# Parameters:
# card - Card object
#
# Returns:
# Integer - between 2-11

def value(card)
  suit = card.to_s.split(//).first
  value  = card.to_s.delete(suit)
  if value.to_i == 0
    value == "A" ? value = 11 : value = 10
  else
    value = value.to_i
  end
  value
end
