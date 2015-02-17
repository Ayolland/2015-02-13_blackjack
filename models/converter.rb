def unicode(card)
  suit_code = {"\u2660"=>"A",
               "\u2665"=>"B",
               "\u2666"=>"C",
               "\u2663"=>"D"}[card.suit]
  if card.num.is_a?(String) || card.num == 10
    num_code = {"Ace"   =>"1",
                "10"    =>"A",
                "Jack"  =>"B",
                "Queen" =>"D",
                "King"  =>"E"}[card.num.to_s]
  else num_code = card.num.to_s
  end
  "&#x1F0" + suit_code + num_code
end

def color(card)
  card.red? ? "red" : "black"
end