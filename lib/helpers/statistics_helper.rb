require 'codebreaker'

module StatisticsHelper
  PATH_TO_STATISTICS = File.expand_path('..', __dir__) + '/storage/statistics.yaml'

  def load_statistic
    if File.file?(PATH_TO_STATISTICS)
      @statistic = Psych.safe_load(File.read(PATH_TO_STATISTICS), [GameStatistic, Time], [], true)
    else
      File.join(PATH_TO_STATISTICS, 'statistic.yaml')
      @statistic = []
    end
  end

  def sort_statistic
    load_statistic.sort_by { |game| [-game.difficulty, game.attempts_used, game.hints_used] }
  end

  def save_statistic
    load_statistic
    @statistic << game.stats
    File.write(PATH_TO_STATISTICS, YAML.dump(@statistic))
  end
end
