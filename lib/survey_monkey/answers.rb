module SurveyMonkey
  class Answers
    def initialize(id, **questions)
      @id = id
      @questions = questions
    end

    def to_h
      {
        id: @id.to_s,
        questions: @questions.each_pair.map do |question, answer|
          {
            id: question.to_s,
            answers: [{ choice_id: answer.to_s }]
          }
        end
      }
    end
  end
end
