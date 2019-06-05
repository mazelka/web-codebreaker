module IOHelper
  def show_welcome
    open_file('lib/storage/welcome_message.txt')
  end

  def show_help
    open_file('lib/storage/help.txt')
  end

  def show_rules
    open_file('lib/storage/rules.txt')
  end

  def show_hints_help
    open_file('lib/storage/hints_help.txt')
  end

  def open_file(path)
    File.open(path) do |f|
      f.each_line do |line|
        puts line
      end
    end
  end
end
