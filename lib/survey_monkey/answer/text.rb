module SurveyMonkey
  module Answer
    class Text
      def initialize(**args)
        @question = args[:question]
        @answer = args[:answer]
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
