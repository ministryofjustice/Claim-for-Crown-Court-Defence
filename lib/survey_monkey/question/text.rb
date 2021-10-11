module SurveyMonkey
  module Question
    class Text < Base
      def parse(text)
        SurveyMonkey::Answer::Text.new(question: @id, answer: text)
      end
    end
  end
end
