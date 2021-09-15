module SurveyMonkey
  class Page
    attr_reader :id, :name

    def initialize(page, page_id, **questions)
      @id = page_id
      @name = page
      @questions = questions
    end

    def question_and_answer(question, answer)
      raise UnregisteredQuestion unless @questions.include?(question)
      raise UnregisteredResponse unless @questions[question][:answers].include?(answer)

      [@questions[question][:id], @questions[question][:answers][answer]]
    end

    def answers(**responses)
      response_codes = responses.each_pair.map do |question, answer|
        question_and_answer(question, answer)
      end.to_h

      Answers.new(@id, **response_codes)
    end
  end
end
