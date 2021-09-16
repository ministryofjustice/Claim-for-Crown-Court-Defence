class FeedbackForm
  Section = Struct.new(:id, :format, :answers)
  Answer = Struct.new(:key, :label, :id, :other) do
    def formatted_id
      return { id: id, other: true } if other

      id
    end
  end

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
        Answer.new('3', 'Yes', 505_487_572),
        Answer.new('2', 'No', 505_487_573),
        Answer.new('1', 'Partially', 505_487_574)
      ]
    )
  end

  def ratings
    Section.new(
      60_742_964, :radio,
      [
        Answer.new('5', 'Very satisfied', 505_488_046),
        Answer.new('4', 'Satisfied', 505_488_047),
        Answer.new('3', 'Neither satisfied nor dissatisified', 505_488_048),
        Answer.new('2', 'Dissatisfied', 505_488_049),
        Answer.new('1', 'Very dissatisfied', 505_488_050)
      ]
    )
  end

  def reasons
    Section.new(
      60_745_386, :checkboxes,
      [
        Answer.new('3', 'Submit an LGFS claim', 505_511_336),
        Answer.new('2', 'Submit an AGFS claim', 505_511_337),
        Answer.new('1', 'Other (please specify)', 505_511_338, other: true)
      ]
    )
  end

  private

  def template_for(section)
    {
      id: section.id,
      format: section.format,
      answers: section.answers.map { |answer| [answer.key, answer.formatted_id] }.to_h
    }
  end
end
