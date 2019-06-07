module ResponseHelper
  def session_present?
    @request.session.key?(:session_id)
  end

  def redirect_to_menu
    Rack::Response.new do |response|
      response.redirect('/menu')
    end
  end

  def redirect_to_game
    Rack::Response.new do |response|
      response.redirect('/game')
    end
  end

  def redirect_to_win
    Rack::Response.new do |response|
      response.redirect('/win')
    end
  end

  def redirect_to_lose
    Rack::Response.new do |response|
      response.redirect('/lose')
    end
  end

  def result
    @request.session[:result]
  end

  def game_present?
    @request.session.key?(:game)
  end

  def reset_game_settings
    @request.session[:result] = []
    @request.session[:hints] = []
    @request.session[:guess] = ''
  end

  def start_game
    @game = Game.new
    @game.start(@request['player_name'], @request['level'])
    @request.session[:game] = game_to_yaml
    reset_game_settings
  end

  def get_result(guess)
    (@game.submit_guess(guess.chars.map(&:to_i)).chars + Array.new(4, 'x')).slice(0, 4)
  end

  def game_required?
    game_path = ['/game', '/submit_answer', '/lose', '/win', '/show_hint']
    game_path.include?(@request.path)
  end

  def game_over?
    @game = game
    @game.stats.all_attempts_used? || @game.won
  end

  def redirect_to_final
    @game.won ? redirect_to_win : redirect_to_lose
  end

  def submit_answer
    @game = game
    @result = get_result(@request['number'])
    save_new_state
    if game_over?
      redirect_to_final
    else
      redirect_to_game
    end
  end

  def save_new_state
    @request.session[:game] = game_to_yaml
    @request.session[:result] = @result
    @request.session[:guess] = @request['number']
  end

  def game_lose
    @game = game
    save_statistic
    reset_game_settings
    Rack::Response.new(render('/lose.html.erb'))
  end

  def game_win
    @game = game
    save_statistic
    reset_game_settings
    Rack::Response.new(render('/win.html.erb'))
  end

  def show_hint
    @game = game
    unless @game.stats.all_hints_used?
      hint = @game.generate_hint
      @request.session[:hints] << hint
      @request.session[:game] = game_to_yaml
    end
    redirect_to_game
  end

  def play_the_game
    if game_over?
      redirect_to_final
    else
      @result = @request.session[:result]
      @hints = @request.session[:hints]
      @guess = @request.session[:guess]
      Rack::Response.new(render('/game.html.erb'))
    end
  end
end
