require_relative '../helpers/iohelper'
require_relative '../helpers/statistic'
require_relative 'game'
require_relative 'user'
require_relative 'game_statistic'

class Interface
  include IOHelper
  include Statistic

  attr_accessor :statistic, :game, :stats, :user

  def initialize
    @statistic = [] unless load_statistic
    show_welcome
  end

  def process_user_input(input)
    # while (input = gets.chomp)
    case input
    when 'rules'
      show_rules
    when 'stats'
      show_stats
    when 'start'
      begin_game
    when 'exit'
      puts 'goodbye!'
    else
      show_help
    end
    'Goodbye!'
    # end
  end

  def begin_game
    @game = Game.new
    @game.start
    @game.setup_game_settings
    # @game.get_user_guess
    # game_win if @game.won
    # game_over if @game.stats.all_attempts_used?
  end

  def game_over
    @game.stats.attempts_used = 0
    show_game_over_message
    prompt_to_start_again
  end

  def game_win
    show_game_won_message
    add_statistics_to_file if save_statistics?
    prompt_to_start_again
  end

  def save_statistics?
    puts "Do you want to save your statistics? enter 'y' if yes:"
    input = gets.chomp
    input == 'y'
  end

  def show_game_over_message
    puts 'Seems like you used all attempts ;('
  end

  def show_game_won_message
    puts 'Congratulations! you won!'
  end

  def prompt_to_start_again
    puts "Try again? Enter 'start'"
    process_user_input
  end
end
