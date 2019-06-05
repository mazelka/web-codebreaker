require_relative '../helpers/iohelper'
require_relative '../helpers/statistic'
require_relative 'interface'
require_relative 'game_statistic'

class Game
  include Statistic
  include IOHelper
  attr_accessor :secret_code, :user, :stats, :won, :statistic

  def initialize(user_name, difficulty)
    @user = user_name
    @secret_code = generate_secret_code
    p @secret_code
    @stats = GameStatistic.new(user_name)
    @stats.setup_difficulty(difficulty)
    @won = false
    @statistic = []
  end

  def start
    @user = User.new
    @stats = GameStatistic.new
    @won = false
    @secret_code = generate_secret_code
    create_hints
  end

  def setup_game_settings
    register_user
    select_difficulty
  end

  def get_user_guess(input)
    until @stats.all_attempts_used?
      puts 'Enter your guess:'
      case input
      when 'exit'
        break puts 'Goodbye!'
      when 'hint'
        show_response_for_hint
      else
        process_game_input(input)
        break if @won
      end
    end
  end

  def break_code(guess)
    @stats.increment_attempts_used
    if code_is_broken?(guess)
      @won = true
      '++++'
    else
      code_copy = @secret_code.dup
      check_strict_match(guess, code_copy)
      check_existing_match(guess, code_copy)
      result(guess)
    end
  end

  def result(guess)
    guess.select { |x| ['+', '-'].include?(x) }.sort.join
  end

  def check_strict_match(guess, code)
    guess.map.with_index do |number, i|
      if number == @secret_code[i]
        guess[i] = '+'
        index = code.index(number)
        code.delete_at(index)
      end
    end
  end

  def check_existing_match(guess, code)
    guess.map.with_index do |number, i|
      if code.include?(number)
        index = code.index(number)
        guess[i] = '-'
        code.delete_at(index)
      end
    end
  end

  def process_game_input(input)
    if valid_guess?(input)
      @stats.increment_attempts_used
      input_in_array = input.split('').map(&:to_i)
      break_code(input_in_array)
    else
      puts 'This in not valid input, try again!'
    end
  end

  def code_is_broken?(guess)
    guess == @secret_code
  end

  def register_user
    @user.set_name
    @stats.name = @user.name
  end

  def select_difficulty
    show_hints_help
    while (input == '1')
      case input
      when '1'
        @stats.set_easy_difficulty
        puts 'Easy level is selected'
        break
      when '2'
        @stats.set_medium_difficulty
        puts 'Medium level is selected'
        break
      when '3'
        @stats.set_hell_difficulty
        puts 'HELL level is selected'
        break
      else
        puts 'This is not valid option :('
        show_hints_help
      end
    end
  end

  def show_hint
    hint = generate_hint
    puts "Your hint: #{hint}."
  end

  def show_response_for_hint
    @stats.all_hints_used? ? show_all_hints_used_message : show_hint
  end

  def show_all_hints_used_message
    puts 'All hints used ;(  try to guess!'
  end

  def generate_hint
    hint = @available_hints.sample
    index = @available_hints.index(hint)
    @available_hints.delete_at(index)
    @stats.increment_hints_used
    hint
  end

  def valid_guess?(guess)
    guess == guess.gsub(/[a-zA-Z]/, '') && guess.size == 4
  end

  def create_hints
    @available_hints = @secret_code.dup
  end

  def generate_secret_code
    4.times.map { Random.rand(1..6) }
  end
end
