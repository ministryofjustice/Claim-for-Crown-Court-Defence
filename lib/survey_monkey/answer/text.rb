module SurveyMonkey
  module Answer
    class Text
      def initialize(question:, answer:)
        @question = question
        @answer = answer
      end

      def to_h
        {
          id: @question.to_s,
          answers: [{ text: @answer.to_s }]
        }
      end
    end
  end
end
