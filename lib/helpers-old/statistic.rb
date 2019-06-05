# require 'terminal-table'
require 'yaml'

module Statistic
  def add_statistics_to_file
    @statistic << @game.stats
    File.write('lib/storage/statistics.yaml', YAML.dump(@statistic))
  end

  def load_statistic
    @statistic = Psych.safe_load(File.read('lib/storage/statistics.yaml'), [GameStatistic, User], [], true)
  end

  def sort_statistic
    load_statistic.sort_by { |game| [-game.difficulty, game.attempts_used, game.hints_used] }
  end

  def show_stats
    puts create_table
  end

  def create_table
    i = 1
    headings = ['Rating', 'Name', 'Difficulty', 'Attempts Total', 'Attempts Used', 'Hints Total', 'Hints Used']
    table = Terminal::Table.new headings: headings do |t|
      sort_statistic.each do |game|
        t << [i, game.name, game.difficulty, game.attempts_total, game.attempts_used, game.hints_total, game.hints_used]
        i += 1
      end
    end
    table
  end
end
