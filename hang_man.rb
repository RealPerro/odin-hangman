require 'pry-byebug' # binding.pry

module GameUtils
  def save_game(obj)
    puts 'savng game...'
  end

  def load_game()
    puts 'loading game...'
  end
end



class HangGame
  include GameUtils

  def self.read_dictionary(file_name = 'words.txt')
    available_words = File.readlines(file_name)
  end


  def select_word(min_size = 5, max_size = 12, dictionary = @@dictionary)
    possible_words = @@dictionary.select { |word| word.length.between?(min_size, max_size)}
    secret_word = possible_words.sample.chomp
  end

  @@dictionary = self.read_dictionary()

  def initialize(player)
    @player = player
    @game_state = 'started'
    @secret_word = select_word.split('')
    @word_mask = '*' * @secret_word.length
    @word_mask = @word_mask.split('')
    @already_guessed = []
    @guess = ''
    @tries_left = 5
  end

  
  def test_report
    puts "word mask count = #{@word_mask.count('*')}"
    puts "secret word = #{@secret_word}"
    puts "guess = #{@guess}"
  end


  def play_letter
    result = 'started'
    @guess = gets[0].to_s.downcase
    if @guess == '1'
      save_game(self)
      @game_state = 'saved' 
    elsif @guess == '2'
      load_game()
      @game_state = 'loaded'
    end

    @already_guessed.push(@guess)
    @tries_left -= 1
    if @secret_word.include?(@guess)
      @tries_left += 1
      update_mask
    end
    @game_state = 'finished' if @tries_left == 0
    @game_state = 'finished' if @word_mask.count('*') == 0
  end

  def update_mask
    @secret_word.each_with_index do |char, idx|
      @word_mask[idx] = char if (@guess == char)
    end
  end

  def display_game
    system ('clear')
    puts "This is Ruby Hangman. Game state = #{@game_state}"
    puts "Hey #{@player}!, you have #{@tries_left} guesses left."
    puts "#{'-' * ((@secret_word.length - 4) / 2)}Word#{'-' * ((@secret_word.length - 4) / 2)}"
    puts "#{@word_mask.join('')}"
    puts puts '-' * @secret_word.length
    if @game_state == 'finished'
      puts "#{@secret_word.join('')}"
    else
      puts '*' * @secret_word.length
    end
    puts '-' * @secret_word.length
    puts ''
    puts "You already tried #{@already_guessed}"
    puts ''
    puts 'Please guess a letter... OR! if you want to save the game enter <1>. To load a saved game press <2>'
    #test_report
  end

  def play
    while @game_state == 'started'
      display_game
      play_letter
    end
    display_game
  end

end

game = HangGame.new("chr")
game.play


