module SurveyMonkey
  module Answer
    class Radio
      def initialize(question:, answer:)
        @question = question
        @answer = answer
      end

      def to_h
        {
          id: @question.to_s,
          answers: [{ choice_id: @answer.to_s }]
        }
      end
    end
  end
end
