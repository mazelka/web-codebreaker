module UIHelper
  def colored_result(result)
    if result == '+'
      'btn-success'
    elsif result == '-'
      'btn-primary'
    else
      'btn-danger'
    end
  end

  def level_to_word(number)
    words = { 1 => 'Simple', 2 => 'Middle', 3 => 'Hard' }
    words[number]
  end
end
