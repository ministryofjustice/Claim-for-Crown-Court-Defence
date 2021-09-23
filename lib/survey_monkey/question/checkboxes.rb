module SurveyMonkey
  module Question
    class Checkboxes < Base
      def initialize(id, answers:)
        super(id)

        @other = nil
        @answers = answers.transform_values do |choice|
          if choice.is_a?(Hash)
            @other = choice[:id] if choice[:other]
            choice[:id]
          else
            choice
          end
        end
      end

      def parse(choices)
        extra = (choices.last.is_a?(Hash) ? choices.pop : {})

        raise UnregisteredResponse if (choices - @answers.keys).any?

        Answer::Checkboxes.new(
          question: @id,
          answers: choices.map { |choice| @answers[choice] },
          other: @other,
          other_text: extra[:other]
        )
      end
    end
  end
end
