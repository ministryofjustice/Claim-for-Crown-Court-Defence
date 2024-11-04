module SurveyMonkey
  class Page
    attr_reader :id, :name, :collector

    def initialize(page, id:, collector:, questions: {})
      @id = id
      @name = page
      @collector = SurveyMonkey.collector_by_name(collector)
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

    def self.unregistered_exception = UnregisteredPage
  end
end
