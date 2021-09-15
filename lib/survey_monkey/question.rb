module SurveyMonkey
  module Question
    def self.create(id, format, **options)
      case format
      when :radio
        Question::Radio.new(id, **options)
      when :checkboxes
        Question::Checkboxes.new(id, **options)
      when :text
        Question::Text.new(id)
      end
    end
  end
end
