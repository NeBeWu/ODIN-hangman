require 'json'

class Game
  def run
    show("Let's play HANGMAN!")

    mode = session_mode

    session = mode == 'new' ? new_session : select_session
    mode == 'new' ? show('New session created.') : show('Session loaded.')

    play(session)
  end

  private

  def show(string)
    string.each_char do |char|
      print char
      sleep(0.1)
    end

    print "\n"
  end

  def session_mode
    puts 'Do you want to play a new session or load a previous one?'
    input = gets.chomp.downcase

    until input == 'new' || input == 'load'
      puts 'Wrong input, please enter "new" to start a new session or "load" to continue a previous one.'
      input = gets.chomp.downcase
    end

    input
  end

  def new_session
    dictionary = load_dictionary('google-10000-english-no-swears.txt')

    secret_word = select_secret_word(dictionary)
    guessing_row = Array.new(secret_word.length, '_')

    GameSession.new(secret_word, 8, [], guessing_row)
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

  def select_session
    saves = Dir.new('saves').children
    show_saves(saves)

    puts 'Choose a file to load.'
    input = gets.chomp

    until /^\d+$/.match?(input) && input.to_i >= 0 && input.to_i < saves.length
      show_saves(saves)

      puts 'Wrong input, please enter a valid save.'
      input = gets.chomp
    end

    load_session(saves[input.to_i])
  end

  def show_saves(saves)
    saves.each_index do |index|
      puts "Save #{index} - #{saves[index]}"
    end
  end

  def load_session(file_name)
    array = JSON.load_file("saves/#{file_name}")

    GameSession.new(*array)
  end

  def play(session)
    until session.number_guesses.zero? || session.guessing_row == session.secret_word
      show_score(session)

      input = player_input

      case input
      when 'save'
        save_session(session)
        show('Session saved.')
        next
      when 'exit'
        return
      else
        update(session, input)
      end
   end

    session.number_guesses.zero? ? loser_message : winner_message
    puts "Secret word: #{session.secret_word.join}"
  end

  def show_score(session)
    puts "Remaining guesses: #{session.number_guesses}"
    puts "Wrong letters: #{session.wrong_letters.join}"
    puts "Guessing row: #{session.guessing_row.join}"
  end

  def player_input
    puts 'Enter a guess (you can also save the game or exit).'
    input = gets.chomp.downcase

    until /^[a-z]$|save|exit/.match?(input)
      puts 'Wrong input, please enter a letter, "save" or "exit".'
      input = gets.chomp.downcase
    end

    input
  end

  def save_session(session)
    file_name = "saves/#{Time.now.to_s[0..18]}.json"
    dump = JSON.dump(session.to_array)

    File.write(file_name, dump)
  end

  def update(session, input)
    session.guessing_row.each_index do |index|
      session.guessing_row[index] = session.secret_word[index] if session.secret_word[index] == input
    end

    unless session.secret_word.include?(input)
      session.number_guesses -= 1
      session.wrong_letters.push(input)
    end
  end

  def loser_message
    puts 'Too bad, you lost!'
  end

  def winner_message
    puts 'Congratulations, you won!'
  end
end

class GameSession
  attr_accessor :secret_word, :number_guesses, :wrong_letters, :guessing_row

  def initialize(secret_word, number_guesses, wrong_letters, guessing_row)
    @secret_word = secret_word
    @number_guesses = number_guesses
    @wrong_letters = wrong_letters
    @guessing_row = guessing_row
  end

  def to_array
    [@secret_word, @number_guesses, @wrong_letters, @guessing_row]
  end
end

game = Game.new
game.run
