require 'pry'

########################################################
class Player
  attr_reader :name
  attr_accessor :standing, :hand, :blackjack

  def initialize(name)
    @standing = false
    @blackjack = false
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

  def discard_hand
    self.hand = Hand.new
    self.standing = false
    self.blackjack = false
  end

  def busted?
    self.hand.bust?
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
class Hand
  attr_accessor :cards

  BLACKJACK_VALUE = 21

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

    if card_values.reduce(:+) > BLACKJACK_VALUE && card_values.include?(11)
      loop do
        card_values[card_values.find_index(11)] = 1
        break if card_values.reduce(:+) <= BLACKJACK_VALUE || !card_values.include?(11)
      end
    end
    card_values.reduce(:+)
  end

  def blackjack?
    if value == BLACKJACK_VALUE && self.cards.count == 2
      true
    else
      false
    end
  end

  def bust?
    if value > BLACKJACK_VALUE
      true
    else
      false
    end
  end

  def add_card(card)
    @cards << card
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
  attr_accessor :deck
  attr_reader :dealer, :player

  def initialize
    player_name = ""
    loop do
      puts "Please enter your name:"
      player_name = gets.chomp
      if player_name == ""
        puts "Please enter a name to continue."
        next
      end
      break
    end

    @deck = Deck.new
    @dealer = Dealer.new("Dealer")
    @player = Player.new(player_name)
  end

  def reset
    self.deck = Deck.new
    self.dealer.discard_hand
    self.player.discard_hand
  end

  def display_table
    sleep(1)
    system 'clear'
    puts "Dealer's Hand:"

    # Determine whether to show hidden dealer card and value.
    if self.player.standing || self.player.busted? || self.dealer.blackjack || self.player.blackjack
      self.dealer.show_hand
      puts "          Value: #{self.dealer.hand.value}"
    else
      self.dealer.show_hand_with_hidden_card
    end

    puts ""
    puts "#{self.player.name}'s Hand:"
    self.player.show_hand
    puts "          Value: #{self.player.hand.value}"
    puts "\n************************************\n"
    puts "**#{self.player.name} is standing**" if self.player.standing
  end

  def deal_initial_cards
    2.times do 
      @player.hit(@deck.deal_card)
      display_table
      @dealer.hit(@deck.deal_card)
      display_table
    end
  end

  def player_turn
    loop do
      puts "Would you like to (hit) or (stand)?"
      hit_or_stand = gets.chomp.downcase

      case hit_or_stand
      when "hit"
        self.player.hit(self.deck.deal_card)
        break if self.player.busted?
      when "stand"
        self.player.stand
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
      if self.dealer.busted?
        break
      elsif self.dealer.hand.value < 17
        self.dealer.hit(self.deck.deal_card)
      else
        self.dealer.stand
        break
      end
      display_table       
    end
  end

  def initial_hand_blackjack?
    if self.player.hand.blackjack? && self.dealer.hand.blackjack?
      self.player.blackjack, self.dealer.blackjack = true
      display_table
      puts "Dealer and #{self.player.name} have Blackjack.  Push."
      true
    elsif self.player.hand.blackjack?
      self.player.blackjack = true
      display_table
      puts "#{self.player.name} wins with Blackjack!"
      true
    elsif self.dealer.hand.blackjack?
      self.dealer.blackjack = true
      display_table
      puts "Dealer wins with Blackjack."
      true
    else
      false
    end
  end

  def determine_game_outcome
    if self.dealer.busted?
      puts "Dealer busts.  #{self.player.name} wins!!"
    elsif self.dealer.hand.value > self.player.hand.value
      puts "Dealer wins."
    elsif self.dealer.hand.value < self.player.hand.value
      puts "#{self.player.name} wins!!"
    else
      puts "Push."
    end
  end

  def start_game
    loop do
      puts "Let's Play Blackjack!"

      play

      puts "\n\n"
      puts "Would you like to play again?  Enter 'yes' to continue."
      if gets.chomp.downcase != 'yes'
        puts "Goodbye."
        break
      end

      reset
    end
  end

  def play
    display_table
    deal_initial_cards

    if initial_hand_blackjack?
      return
    end

    player_turn
    display_table

    if self.player.busted?
      puts "#{self.player.name} busts.  Dealer wins."
      return
    end

    dealer_turn
    display_table

    determine_game_outcome     
  end
end

blackjack = Blackjack.new
blackjack.start_game