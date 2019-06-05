require 'erb'
require 'pry'
require 'yaml'
require 'codebreaker'
# require_relative 'codebreaker/game'

class Box
  def self.get
    @@codebreaker ||= Codebreaker.new
  end
end

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    binding.pry
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
    when '/game'
      if @request.session['game'].nil? || !session_present?
        Rack::Response.new do |response|
          response.redirect('/menu')
        end
      else
        @game = game
        p @game
        p @game.secret_code
        p @result = result.chars
        Rack::Response.new(render('/game.html.erb'))
      end
    when '/submit_answer'
      @game = game
      p @request['number'].chars
      @result = @game.break_code(@request['number'].chars.map(&:to_i))
      p @result
      if @game.stats.all_attempts_used? && @result != '++++'
        Rack::Response.new do |response|
          response.redirect('/menu') unless session_present?
          response.set_cookie('result', @result)
          response.set_cookie('game', YAML.dump(@game))
          response.redirect('/lose')
        end
      else
        Rack::Response.new do |response|
          response.redirect('/menu') unless session_present?
          response.set_cookie('result', @result)
          response.set_cookie('game', YAML.dump(@game))
          response.redirect('/game')
        end
      end
    when '/menu'
      Rack::Response.new(render('/menu.html.erb')) do
        # binding.pry
        # @request.session[]
        @request.session[:name] = 'John Doe' unless session_present?
        @request.cookies['rack.session'] = @request.env['rack.session'] unless session_present?
      end
    when '/lose'
      @game = game
      Rack::Response.new(render('/lose.html.erb')) do |response|
        response.redirect('/menu') unless session_present?
        response.set_cookie('result', '')
        @request.session[:name] = 'John Doe' unless session_present?
      end
    when '/win'
      @game = game
      Rack::Response.new(render('/win.html.erb')) do |response|
        response.redirect('/menu') unless session_present?
        response.set_cookie('result', '')
        @request.session[:name] = 'John Doe' unless session_present?
      end
    when '/statistics'
      @game = game
      @sorted_stats = @game.sort_statistic
      Rack::Response.new(render('/statistics.html.erb')) do |response|
        response.redirect('/menu') unless session_present?
        response.set_cookie('result', '')
        @request.session[:name] = 'John Doe' unless session_present?
      end
    when '/start_game'
      code = Codebreaker.new
      game = code.start_game(@request['player_name'], @request['level'])
      Rack::Response.new do |response|
        response.redirect('/menu') unless session_present?
        response.set_cookie('game', YAML.dump(game))
        response.redirect('/game')
      end
    else Rack::Response.new('Not Found', 404)
    end
  end

  private

  def render(template)
    path = File.expand_path("../../codebreaker-web-template/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def session_present?
    @request.session.key?(:name)
  end

  def game
    @game = Psych.safe_load(@request.session['game'], [Game, GameStatistic, Time], [], true)
    binding.pry
    @game
  end

  def result
    @request.cookies['result'] || ''
  end
end
