class Game
  def run
    dictionary = load_dictionary('google-10000-english-no-swears.txt')

    secret_word = select_secret_word(dictionary)

    play(secret_word)
  end

  def load_dictionary(file)
    File.readlines(file).map(&:chomp)
  end

  def select_secret_word(dictionary)
    secret_word = dictionary.sample

    until secret_word.length >= 5 && secret_word.length <= 12
      secret_word = dictionary.sample
    end

    secret_word.split('')
  end

  def play(secret_word)
    @number_guesses = 8
    incorrect_letters = []
    guessing_row = Array.new(secret_word.length, '_')

    until @number_guesses.zero? || guessing_row == secret_word
      show_score(@number_guesses, incorrect_letters, guessing_row)

      input = player_input

      update(incorrect_letters, guessing_row, secret_word, input)
    end

    @number_guesses.zero? ? loser_message : winner_message
    puts "Secret word: #{secret_word.join}"
  end

  def show_score(number_guesses, incorrect_letters, guessing_row)
    puts "Remaining guesses: #{number_guesses}"
    puts "Wrong letters: #{incorrect_letters.join}"
    puts "Guessing row: #{guessing_row.join}"
  end

  def player_input
    puts 'Enter a guess'
    input = gets.chomp.downcase

    until /^[a-z]$/.match?(input)
      puts 'Wrong input, please enter a letter.'
      input = gets.chomp.downcase
    end

    input
  end

  def update(incorrect_letters, guessing_row, secret_word, input)
    guessing_row.each_index do |index|
      guessing_row[index] = secret_word[index] if secret_word[index] == input
    end

    unless secret_word.include?(input)
      @number_guesses -= 1
      incorrect_letters.push(input)
    end
  end

  def loser_message
    puts 'Too bad, you lost!'
  end

  def winner_message
    puts 'Congratulations, you won!'
  end
end

game = Game.new
game.run
