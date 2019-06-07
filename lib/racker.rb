require 'erb'
require 'pry'
require 'codebreaker'
require_relative 'helpers/response_helper'
require_relative 'helpers/statistics_helper'
require_relative 'helpers/ui_helper'

class Racker
  include ResponseHelper
  include StatisticsHelper
  include UIHelper

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    # binding.pry
    @request.session[:init] = true
    if session_present?
      response_with_session
    else
      redirect_to_menu
    end
  end

  private

  def response_with_session
    if game_required?
      response_with_game
    else
      response_wihtout_game
    end
  end

  def response_with_game
    game_present? ? response_with_game_and_session : redirect_to_menu
  end

  def response_with_game_and_session
    case @request.path
    when '/game'
      play_the_game
    when '/submit_answer'
      submit_answer
    when '/lose'
      game_lose
    when '/win'
      game_win
    when '/show_hint'
      show_hint
    end
  end

  def response_wihtout_game
    case @request.path
    when '/rules'
      Rack::Response.new(render('/rules.html.erb'))
    when '/menu'
      Rack::Response.new(render('/menu.html.erb'))
    when '/'
      redirect_to_menu
    when '/statistics'
      @statistic = sort_statistic
      Rack::Response.new(render('/statistics.html.erb'))
    when '/start_game'
      start_game
      redirect_to_game
    else
      Rack::Response.new('Not Found', 404)
    end
  end

  def render(template)
    path = File.expand_path("../../codebreaker-web-template/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def game_to_yaml
    YAML.dump(@game)
  end

  def game
    @game = Psych.safe_load(@request.session[:game], [Game, GameStatistic, Time], [], true)
  end
end
