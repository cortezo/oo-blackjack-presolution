require 'pry'

########################################################
class Player
  attr_reader :name
  attr_accessor :standing, :hand

  def initialize(name)
    @standing = false
    @hand = Hand.new
    @name = name
  end

  def stand
    self.standing = true
    puts "#{self.name} stands."
  end

  def hit(card)
    self.hand.add_card(card)
  end

  def show_hand
    self.hand.cards.each { |card| puts card}
  end
end

########################################################
class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def value
    card_values = [0]
    self.cards.each do |card|
      if card.rank.match(/[B-Z]/)
        card_values << 10
      elsif card.rank.match("A")
        card_values << 11
      else
        card_values << card.rank.to_i
      end
    end

    if card_values.reduce(:+) > 21 && card_values.include?(11)
      loop do
        card_values[card_values.find_index(11)] = 1
        break if card_values.reduce(:+) <= 21 || !card_values.include?(11)
      end
    end
    card_values.reduce(:+)
  end

  def add_card(card)
    @cards << card
  end
end

########################################################
class Dealer < Player
  def show_hand_with_hidden_card
    self.hand.cards.each_with_index do |card, i|
      if i == 1
        puts "*** Hidden Card ***"  # Second card dealt to Dealer is face-down
      else
        puts card
      end
    end
  end
end

########################################################
class Card
  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{self.rank} of #{self.suit}"
  end
end

########################################################
class Deck
  attr_reader :cards

  RANKS = %w{2 3 4 5 6 7 8 9 10 J Q K A}
  SUITS = %w{Hearts Spades Diamonds Clubs}

  def initialize
    @cards = []

    SUITS.each do |suit|
      RANKS.each do |rank|
        @cards << Card.new(rank, suit)
      end
    end

    @cards.shuffle!
  end

  def to_s
    self.cards.each do |card|
      puts card
    end
  end

  def deal_card
    self.cards.pop
  end
end

########################################################
class Blackjack

  def initialize
    puts "Please enter your name:"
    player_name = gets.chomp

    @deck = Deck.new
    @dealer = Dealer.new("Dealer")
    @player = Player.new(player_name)
  end

  def reset
    @deck = Deck.new
    @dealer.hand = Hand.new
    @player.hand = Hand.new
  end

  def display_table
    sleep(1)
    system 'clear'
    puts "Dealer's Hand:"
    if @player.standing
      @dealer.show_hand
      puts "          Value: #{@dealer.hand.value}"
    else
      @dealer.show_hand_with_hidden_card
    end
    puts ""
    puts "#{@player.name}'s Hand:"
    @player.show_hand
    puts "          Value: #{@player.hand.value}"
    puts ""
    puts "**#{@player.name} is standing**" if @player.standing
  end

  def player_turn
    loop do
      puts "Would you like to (hit) or (stand)?"
      hit_or_stand = gets.chomp.downcase

      case hit_or_stand
      when "hit"
        @player.hit(@deck.deal_card)
        break if @player.hand.value > 21
      when "stand"
        @player.stand
        break
      else
        puts "Please enter a valid input of 'hit' or 'stand'"
        next
      end
      display_table
    end
  end

  def dealer_turn
    loop do
      if @dealer.hand.value > 21
        break
      elsif @dealer.hand.value < 17
        @dealer.hit(@deck.deal_card)
      else
        @dealer.stand
        break
      end
      display_table       
    end
  end

  def start_game
    loop do
      puts "Let's Play Blackjack!"
      play
      puts ""
      puts "Would you like to play again?  Enter 'yes' to continue."
      if gets.chomp.downcase != 'yes'
        puts "Goodbye."
        break
      end
      reset
    end
  end

  def play
    # Initial dealt cards
    display_table
    2.times do 
      @player.hit(@deck.deal_card)
      display_table
      @dealer.hit(@deck.deal_card)
      display_table
    end

    player_turn
    display_table

    # Check for player bust
    if @player.hand.value > 21
      puts "#{@player.name} busts.  Dealer wins."
      return
    end

    dealer_turn
    display_table

    if @dealer.hand.value > 21
      puts "Dealer busts.  #{@player.name} wins!!"
    elsif @dealer.hand.value > @player.hand.value
      puts "Dealer wins."
    elsif @dealer.hand.value < @player.hand.value
      puts "Player wins!!"
    else
      puts "Push."
    end
      
  end
end

blackjack = Blackjack.new
blackjack.start_game