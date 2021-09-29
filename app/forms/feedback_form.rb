class FeedbackForm
  Section = Struct.new(:id, :format, :answers)

  def name
    :feedback
  end

  def id
    25_473_840
  end

  def template
    {
      tasks: template_for(tasks),
      ratings: template_for(ratings),
      reasons: template_for(reasons),
      comments: { id: 60_742_937, format: :text }
    }
  end

  def tasks
    Section.new(
      60_742_936, :radio,
      [
        FormAnswer.new('3', 'Yes', 505_487_572),
        FormAnswer.new('2', 'No', 505_487_573),
        FormAnswer.new('1', 'Partially', 505_487_574)
      ]
    )
  end

  def ratings
    Section.new(
      60_742_964, :radio,
      [
        FormAnswer.new('5', 'Very satisfied', 505_488_046),
        FormAnswer.new('4', 'Satisfied', 505_488_047),
        FormAnswer.new('3', 'Neither satisfied nor dissatisified', 505_488_048),
        FormAnswer.new('2', 'Dissatisfied', 505_488_049),
        FormAnswer.new('1', 'Very dissatisfied', 505_488_050)
      ]
    )
  end

  def reasons
    Section.new(
      60_745_386, :checkboxes,
      [
        FormAnswer.new('3', 'Submit an LGFS claim', 505_511_336),
        FormAnswer.new('2', 'Submit an AGFS claim', 505_511_337),
        FormAnswer.new('1', 'Other (please specify)', 505_511_338, other: true)
      ]
    )
  end

  private

  def template_for(section)
    {
      id: section.id,
      format: section.format,
      answers: section.answers.map { |answer| [answer.key, answer.id] }.to_h
    }
  end
end
