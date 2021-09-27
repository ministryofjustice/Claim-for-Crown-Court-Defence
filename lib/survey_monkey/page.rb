module SurveyMonkey
  class Page
    attr_reader :id, :name

    def initialize(page, page_id, **questions)
      @id = page_id
      @name = page
      @questions = questions.transform_values do |options|
        Question.create(options[:id], options[:format], **options)
      end
    end

    def question_and_answer(question, answer)
      raise UnregisteredQuestion unless @questions.include?(question)

      @questions[question].parse(answer)
    end

    def answers(**responses)
      response_codes = responses.each_pair.map do |question, answer|
        question_and_answer(question, answer)
      end

      Answers.new(@id, *response_codes)
    end
  end
end
