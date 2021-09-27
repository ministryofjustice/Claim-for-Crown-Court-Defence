class FeedbackForm
  Answer = Struct.new(:key, :label, :id, :other)

  def name
    :feedback
  end

  def id
    25_473_840
  end

  def template
    {
      tasks: survey_monkey_tamplate_for(tasks),
      ratings: survey_monkey_tamplate_for(ratings),
      reasons: survey_monkey_tamplate_for(reasons),
      comments: { id: 60_742_937, format: :text }
    }
  end

  def tasks
    {
      id: 60_742_936, format: :radio,
      answers: [
        Answer.new('3', 'Yes', 505_487_572),
        Answer.new('2', 'No', 505_487_573),
        Answer.new('1', 'Partially', 505_487_574)
      ]
    }
  end

  def ratings
    {
      id: 60_742_964, format: :radio,
      answers: [
        Answer.new('5', 'Very satisfied', 505_488_046),
        Answer.new('4', 'Satisfied', 505_488_047),
        Answer.new('3', 'Neither satisfied nor dissatisified', 505_488_048),
        Answer.new('2', 'Dissatisfied', 505_488_049),
        Answer.new('1', 'Very dissatisfied', 505_488_050)
      ]
    }
  end

  def reasons
    {
      id: 60_745_386, format: :checkboxes,
      answers: [
        Answer.new('3', 'Submit an LGFS claim', 505_511_336),
        Answer.new('2', 'Submit an AGFS claim', 505_511_337),
        Answer.new('1', 'Other (please specify)', 505_511_338, true)
      ]
    }
  end

  private

  def survey_monkey_tamplate_for(section)
    {
      id: section[:id],
      format: section[:format],
      answers: section[:answers].map do |answer|
        [answer.key, answer.other ? { id: answer.id, other: true } : answer.id]
      end.to_h
    }
  end
end
