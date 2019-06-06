require 'codebreaker'

module Statistics
  def load_statistic
    @statistic = Psych.safe_load(File.read(File.expand_path('..', __dir__) + '/storage/statistics.yaml'), [GameStatistic, Time], [], true)
  end

  def sort_statistic
    load_statistic.sort_by { |game| [-game.difficulty, game.attempts_used, game.hints_used] }
  end

  def save_statistic
    load_statistic
    @statistic << game.stats
    File.write(File.expand_path('..', __dir__) + '/storage/statistics.yaml', YAML.dump(@statistic))
  end
end
