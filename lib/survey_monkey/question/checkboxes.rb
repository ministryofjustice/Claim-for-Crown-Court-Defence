module SurveyMonkey
  module Question
    class Checkboxes < Base
      def initialize(id, answers:)
        super(id)

        @other = nil
        @answers = answers.transform_values { |choice| id_for_choice(choice) }
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

      private

      def id_for_choice(choice)
        return choice unless choice.is_a?(Hash)

        @other = choice[:id] if choice[:other]
        choice[:id]
      end
    end
  end
end
