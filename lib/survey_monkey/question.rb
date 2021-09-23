module SurveyMonkey
  module Question
    def self.create(id, format, **options)
      case format
      when :radio
        Question::Radio.new(id, answers: options[:answers])
      when :checkboxes
        Question::Checkboxes.new(id, answers: options[:answers])
      when :text
        Question::Text.new(id)
      end
    end
  end
end
