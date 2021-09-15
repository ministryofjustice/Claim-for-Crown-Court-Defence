module SurveyMonkey
  class Answers
    def initialize(id, *answers)
      @id = id
      @answers = answers
    end

    def to_h
      {
        id: @id.to_s,
        questions: @answers.map(&:to_h)
      }
    end
  end
end
