INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'

WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                [[1, 5, 9], [3, 5, 7]]              # diagonals

STARTING_PLAYER = 'Player'
current_player = STARTING_PLAYER

def prompt(message)
  puts "=> #{message}"
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
  system 'clear'
  puts "You are '#{PLAYER_MARKER}' <=> Computer is '#{COMPUTER_MARKER}'."
  puts ""
  puts "     |     |"
  puts " #{brd[1]}   |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts " #{brd[4]}   |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts " #{brd[7]}   |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end
# rubocop:enable Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def joinor(arr)
  case arr.size
  when 0 then ''
  when 1 then arr.first
  when 2 then arr.join(" or ")
  else
    arr[-1] = "or #{arr.last}"
    arr.join(', ')
  end
end

def player_selects_square!(brd)
  square = INITIAL_MARKER
  loop do
    prompt "Choose a square: #{joinor(empty_squares(brd))}"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid choice."
  end
  brd[square] = PLAYER_MARKER
end

def find_at_risk_square(line, board, marker)
  if board.values_at(*line).count(marker) == 2
    return board.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  end
  nil
end

def computer_selects_square!(brd)
  square = nil
  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, COMPUTER_MARKER)
    break if square
  end

  if !square
    WINNING_LINES.each do |line|
      square = find_at_risk_square(line, brd, PLAYER_MARKER)
      break if square
    end
  end

  if !square && brd[5] == INITIAL_MARKER
    square = 5
  elsif !square
    square = empty_squares(brd).sample
  end

  brd[square] = COMPUTER_MARKER
end

def place_piece!(brd, current_player)
  if current_player == 'Player'
    player_selects_square!(brd)
  end

  if current_player == 'Computer'
    computer_selects_square!(brd)
  end
end

def alternate_player(current_player)
  if current_player == 'Player'
    'Computer'
  elsif current_player == 'Computer'
    'Player'
  end
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

loop do
  player_victories = 0
  computer_victories = 0
  loop do
    board = initialize_board
    loop do
      display_board(board)
      place_piece!(board, current_player)
      current_player = alternate_player(current_player)
      break if someone_won?(board) || board_full?(board)
    end

    display_board(board)

    if someone_won?(board)
      prompt "#{detect_winner(board)} won!"
      player_victories += 1 if detect_winner(board) == 'Player'
      computer_victories += 1 if detect_winner(board) == 'Computer'
    else
      prompt "It's a tie."
    end
    prompt "You have #{player_victories} wins."
    prompt "Computer has #{computer_victories} wins."
    sleep 1.5

    if player_victories == 5
      prompt "You won the match!"
    elsif computer_victories == 5
      prompt "Computer won the match."
      break
    end
  end
  prompt "Do you want to play again? (y/n)"
  play_again = gets.chomp.downcase
  break unless play_again.start_with?('y')
end

prompt "Good-bye.  Thank you for playing!"