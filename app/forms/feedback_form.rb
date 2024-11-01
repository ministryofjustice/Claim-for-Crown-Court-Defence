class FeedbackForm
  Section = Struct.new(:id, :format, :answers)
  Answer = Struct.new(:key, :label, :id, :other) do
    def formatted_id
      return { id:, other: true } if other

      id
    end
  end

  def name = :feedback
  def id = 26_019_002
  def collector = :feedback

  def template
    {
      tasks: template_for(tasks),
      ratings: template_for(ratings),
      reasons: template_for(reasons),
      comments: { id: 62_469_815, format: :text }
    }
  end

  def tasks
    Section.new(
      62_469_808, :radio,
      [
        Answer.new('3', 'Yes', 519_552_297),
        Answer.new('2', 'No', 519_552_298),
        Answer.new('1', 'Partially', 519_552_299)
      ]
    )
  end

  def ratings
    Section.new(
      62_469_811, :radio,
      [
        Answer.new('5', 'Very satisfied', 519_552_314),
        Answer.new('4', 'Satisfied', 519_552_335),
        Answer.new('3', 'Neither satisfied nor dissatisfied', 519_552_315),
        Answer.new('2', 'Dissatisfied', 519_552_316),
        Answer.new('1', 'Very dissatisfied', 519_552_317)
      ]
    )
  end

  def reasons
    Section.new(
      62_469_839, :checkboxes,
      [
        Answer.new('3', 'Submit a LGFS claim', 519_552_475),
        Answer.new('2', 'Submit an AGFS claim', 519_552_476),
        Answer.new('1', 'Other (please specify)', 519_552_477, other: true)
      ]
    )
  end

  private

  def template_for(section)
    {
      id: section.id,
      format: section.format,
      answers: section.answers.to_h { |answer| [answer.key, answer.formatted_id] }
    }
  end
end
