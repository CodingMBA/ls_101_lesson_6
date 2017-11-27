SUITS = ['H', 'D', 'C', 'S']
VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
GAME = 31
DEALER_STAYS = GAME - 4

def prompt(message)
  puts "=> #{message}"
end

def initialize_deck
  VALUES.product(SUITS).shuffle
end

def total(cards)
  # cards = [['H', '3'], ['S', 'Q'], ... ]
  values = cards.map { |card| card[0] }

  sum = 0
  values.each do |value|
    if value == "A"
      sum += (GAME - 10)
    elsif value.to_i == 0 # J, Q, K
      sum += 10
    else
      sum += value.to_i
    end
  end

  # correct for Aces
  values.select { |value| value == "A" }.count.times do
    sum -= 10 if sum > GAME
  end

  sum
end

def busted?(cards)
  total(cards) > GAME
end

def detect_result(dealer_hand, player_hand)
  player_total = total(player_hand)
  dealer_total = total(dealer_hand)

  if player_total > GAME
    :player_busted
  elsif dealer_total > GAME
    :dealer_busted
  elsif player_total > dealer_total
    :player
  elsif dealer_total > player_total
    :dealer
  else
    :tie
  end
end

def display_result(dealer_hand, player_hand)
  result = detect_result(dealer_hand, player_hand)

  case result
  when :player_busted
    prompt "You busted.  Dealer wins this round."
  when :dealer_busted
    prompt "Dealer busted.  You win this round!"
  when :player
    prompt "You win this round!"
  when :dealer
    prompt "Dealer wins this round"
  when :tie
    prompt "This round is a tie."
  end
end

def round_end_summary(dealer_hand, dealer_total, player_hand, player_total)
  puts "\n=============="
  prompt "Dealer has #{dealer_hand}, for a total of: #{dealer_total}"
  prompt "Player has #{player_hand}, for a total of: #{player_total}"
  puts "==============\n\n"
  sleep 2
  display_result(dealer_hand, player_hand)
end

def match_status(dealer_hand, dealer_score, player_hand, player_score)
  winner = detect_result(dealer_hand, player_hand)
  if winner == :dealer or winner == :player_busted
    dealer_score += 1
  elsif winner == :player or winner == :dealer_busted
    player_score += 1
  end
  prompt "Dealer has #{dealer_score} wins."
  prompt "Player has #{player_score} wins."
  return dealer_score, player_score
end

def match_won?(dealer_score, player_score)
  if dealer_score >= 5
    prompt "=> Dealer wins the match. <==<=="
    return true
  elsif player_score >= 5
    prompt "=> Player wins the match! <==<=="
    return true
  else
    false
  end
end

def play_again?
  puts "-------------------------"
  prompt "Press 'y' to play again or 'n' to quit."
  answer = gets.chomp
  answer.downcase.start_with?('y')
end



loop do # match loop
  dealer_score = 0
  player_score = 0
  puts "Let's Play #{GAME.to_s}!!"
    loop do # round loop
    sleep 1
    system 'clear'

    deck = initialize_deck
    player_hand = []
    dealer_hand = []
    player_total = 0
    dealer_total = 0
  
    # initial deal
    2.times do
      player_hand << deck.pop
      dealer_hand << deck.pop
    end
  
    player_total = total(player_hand)
    dealer_total = total(dealer_hand)
    
    prompt "Dealer has #{dealer_hand[0]} and ? \n\n"
    sleep 1
    prompt "Your cards are #{player_hand[0]} and #{player_hand[1]}."
    prompt "You have #{player_total} \n\n"
    sleep 1
    # player turn
    loop do
      player_choice = nil
      loop do
        prompt "Press 'h' to hit or 's' to stay."
        player_choice = gets.chomp.downcase
        break if ['h', 's'].include?(player_choice)
        prompt "You must enter 'h' or 's'."
      end
  
      if player_choice == 'h'
        player_hand << deck.pop
        # prompt "You received another card."
        prompt "Your cards are now: #{player_hand}"
         player_total = total(player_hand)
        prompt "Your total is now: #{player_total}"
      end
  
      break if player_choice == 's' || busted?(player_hand)
    end
  
    if busted?(player_hand)
      round_end_summary(dealer_hand, dealer_total, player_hand, player_total)
      sleep 2
      dealer_score, player_score = match_status(dealer_hand, dealer_score, player_hand, player_score)
      sleep 1
      match_won?(dealer_score, player_score) ? break : next
    else
      prompt "You stayed at #{player_total}.\n\n"
    end
  
    sleep 1
  
    #  dealer turn
    prompt "Dealer's turn..."
    sleep 1
    prompt "Dealer's cards are #{dealer_hand}."
    prompt "Dealer has #{dealer_total}."
    sleep 2
    loop do
      break if total(dealer_hand) >= DEALER_STAYS
  
      prompt "Dealer hits."
      dealer_hand << deck.pop
      dealer_total = total(dealer_hand)
      prompt "Dealers cards are now: #{dealer_hand}"
      sleep 2
    end
  
    if busted?(dealer_hand)
      round_end_summary(dealer_hand, dealer_total, player_hand, player_total)
      sleep 2
      dealer_score, player_score = match_status(dealer_hand, dealer_score, player_hand, player_score)
      sleep 1
      match_won?(dealer_score, player_score) ? break : next
    else
      prompt "Dealer stays at #{dealer_total}"
    end
  
    round_end_summary(dealer_hand, dealer_total, player_hand, player_total)
  
    sleep 2
    dealer_score, player_score = match_status(dealer_hand, dealer_score, player_hand, player_score)
    sleep 1
    break if match_won?(dealer_score, player_score)
    end
  break unless play_again?
end

prompt "Thank you for playing! Good bye!"
