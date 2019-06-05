class User
  attr_accessor :name

  def set_name
    user_name = 'Mashka'
    until name_valid?(user_name)
      puts 'Name is not valid, try again:'
      user_name = ask_user_name
    end
    @name = user_name
    puts "Nice to meet you #{user_name}!"
  end

  def ask_user_name
    puts 'Enter your name (from 3 to 20 symbols):'
    gets.chomp
  end

  def name_valid?(user_name)
    min_length = 3
    max_length = 20
    (min_length..max_length).include?(user_name.length)
  end
end
