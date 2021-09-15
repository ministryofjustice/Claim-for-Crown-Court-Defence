module SurveyMonkey
  module Answer
    class Radio
      def initialize(**args)
        @question = args[:question]
        @answer = args[:answer]
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
