class Shoe
  
  attr_reader :cards
  
  def initialize(size = 1)
    @cards = []
    size.times do
      temp_deck = Deck.new.cards.shuffle
      temp_deck.each do
        @cards << temp_deck.pop
      end
    end
  end
  
  def deal
    @cards.pop
  end
end