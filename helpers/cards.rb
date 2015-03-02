module CardOperations

  # test_hand
  # Generates a hand of nine random cards for display testing.
  #
  # Returns:
  # Array - filled with card strings
  
  def test_hand
    @shoe = Shoe.new
    hand =[]
    9.times { hand << @shoe.deal.to_s}
    hand
  end
  
  def set_example_card
    @hand = [] << Shoe.new.deal.to_s
  end

  # unicode
  # Converts a card object or string into its HTML Unicode character.
  #
  # Parameters:
  # card - Card object or string.
  #
  # Returns:
  # String - HTML Unicode character.

  def unicode(card)
    suit, num = suit_num(card)
    suit_code = {"\u2660"=>"A",
                 "\u2665"=>"B",
                 "\u2666"=>"C",
                 "\u2663"=>"D"}[suit]
    if num.to_i == 0 || num.to_i == 10
      num_code = {"A"  =>"1",
                  "10" =>"A",
                  "J"  =>"B",
                  "Q"  =>"D",
                  "K"  =>"E"}[num]
    else num_code = num
    end
    "&#x1F0" + suit_code + num_code
  end
  
  # suit_num
  # gets the one-letter suit string, and the number of card.
  #
  # Parameters:
  # card - Card object or string.
  #
  # Returns:
  # suit, num - both strings.
  
  def suit_num(card)
    suit = card.to_s.split(//).first
    num  = card.to_s.delete(suit)
    return suit, num
  end
  
  # color
  # gets the color of a card as a string.
  #
  # Parameters:
  # card - Card object or string.
  #
  # Returns:
  # string
  
  def color(card)
    suit, num = suit_num(card)
    suit == "\u2665" || suit == "\u2666" ? "red" : "black"
  end

end