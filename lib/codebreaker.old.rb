require_relative 'codebreaker/interface'
require_relative 'codebreaker/game'

class Codebreaker
  attr_accessor :game, :name, :answer

  def start_game(name, level)
    @name = name
    @game = Game.new(name, level)
    p @game
  end

  def break(number)
    @answer = @game.break_code(number.chars.map(&:to_i))
    p number.chars
  end
end
