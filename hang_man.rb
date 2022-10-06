require 'pry-byebug' # binding.pry
require 'json'

class HangGame

  def self.read_dictionary(file_name = 'words.txt')
    available_words = File.readlines(file_name)
  end

  def select_word(min_size = 6, max_size = 12, dictionary = @@dictionary)
    possible_words = @@dictionary.select { |word| word.length.between?(min_size, max_size)}
    secret_word = possible_words.sample.chomp
  end

  @@dictionary = self.read_dictionary()

  def initialize(player)
    @player = player.to_s
    @game_state = 'started'
    @secret_word = select_word.split('')
    @word_mask = '*' * @secret_word.length
    @word_mask = @word_mask.split('')
    @already_guessed = []
    @guess = ''
    @tries_left = 5
    @message = ''
  end

  def to_json
    JSON.dump({
    :player => @player,
    :game_state => @game_state,
    :secret_word => @secret_word,
    :word_mask => @word_mask,
    :already_guessed => @already_guessed,
    :tries_left => @tries_left
    })
  end
  
  def from_json(string)
    data = JSON.load(string)
    @player = data['player']
    @game_state = data['game_state']
    @secret_word = data['secret_word']
    @word_mask = data['word_mask']
    @already_guessed = data['already_guessed']
    @guess = ''
    @tries_left = data['tries_left']
  end

  def save_game
    puts 'saving game...'
    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
    file_name = "saved_games/#{@player}.json"
    File.open(file_name, 'w') do |file|
      file.puts to_json
    end
  end

  def load_game
    file_name = "saved_games/#{@player}.json"
    puts 'loading game...'
    begin
      game_data = File.read(file_name)
      from_json(game_data)
    rescue
      @message = "No file to load for this player."
    end
  end

  def play_letter
    result = 'started'
    @guess = gets[0].to_s.downcase

    if @guess == '1'
      save_game
      @game_state = 'saved'
    elsif @guess == '2'
      load_game
      @game_state = 'started'
    else
      @message = ''
      @already_guessed.push(@guess)
      @tries_left -= 1
      if @secret_word.include?(@guess)
        @tries_left += 1
        update_mask
      end
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
    puts "Hey #{@player}!, you have #{@tries_left} guesses left. #{@message}"
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
  end

  def play
    puts "Please enter your name"
    while @game_state == 'started'
      display_game
      play_letter
    end
    display_game
  end

end

game = HangGame.new("ger")
game.play


