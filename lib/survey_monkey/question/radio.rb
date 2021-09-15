module SurveyMonkey
  module Question
    class Radio < Base
      def initialize(id, answers:)
        super(id)

        @answers = answers
      end

      def parse(answer)
        raise UnregisteredResponse unless @answers.include?(answer)

        Answer::Radio.new(question: @id, answer: @answers[answer])
      end
    end
  end
end
