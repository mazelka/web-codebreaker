# require_relative 'interface'
# require_relative 'game'
require_relative '../helpers/statistic'
# require_relative '../helpers/iohelper'
# require 'yaml'

class GameStatistic
  include Statistic
  attr_accessor :difficulty, :attempts_total, :attempts_used, :hints_total, :hints_used, :name

  def initialize(user_name)
    @name = user_name
    @attempts_used = 0
    @hints_used = 0
    @hints_total = 0
    @difficulty = ''
    @attempts_total = 0
  end

  def attempts_available
    @attempts_total - @attempts_used
  end

  def hints_available
    @hints_total - @hints_used
  end

  def increment_attempts_used
    @attempts_used += 1
  end

  def all_attempts_used?
    @attempts_used == @attempts_total
  end

  def all_hints_used?
    @hints_used == @hints_total
  end

  def increment_hints_used
    @hints_used += 1
  end

  def setup_difficulty(difficulty)
    p 'set up diff'
    case difficulty
    when 'simple'
      set_easy_difficulty
    when 'middle'
      set_medium_difficulty
    when 'hard'
      set_hell_difficulty
    end
  end

  def set_easy_difficulty
    @difficulty = 'Simple'
    @attempts_total = 15
    @hints_total = 2
  end

  def set_medium_difficulty
    @difficulty = 'Middle'
    @attempts_total = 10
    @hints_total = 1
  end

  def set_hell_difficulty
    @difficulty = 'Hard'
    @attempts_total = 5
    @hints_total = 1
  end
end
