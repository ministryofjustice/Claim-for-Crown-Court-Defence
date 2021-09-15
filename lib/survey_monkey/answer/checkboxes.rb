module SurveyMonkey
  module Answer
    class Checkboxes
      def initialize(question:, answers:, other: nil, other_text: nil)
        @question = question
        @answers = answers
        @other = other
        @other_text = other_text
      end

      def to_h
        {
          id: @question.to_s,
          answers: @answers.map { |answer| answer_hash(answer) }
        }
      end

      private

      def answer_hash(answer)
        return { other_id: answer.to_s, text: @other_text.to_s } if answer == @other

        { choice_id: answer.to_s }
      end
    end
  end
end
