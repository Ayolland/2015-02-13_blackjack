module CardOperations

  def test_hand
    @shoe = Shoe.new
    hand =[]
    9.times { hand << @shoe.deal.to_s}
    hand
  end

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
  
  def suit_num(card)
    suit = card.to_s.split(//).first
    num  = card.to_s.delete(suit)
    return suit, num
  end
  
  def color(card)
    suit, num = suit_num(card)
    suit == "\u2665" || suit == "\u2666" ? "red" : "black"
  end

end