require 'rspec/expectations'

RSpec::Matchers.define :have_date_error_if_earlier_than_other_field do |options|
  options.assert_valid_keys :field, :other_field, :message, :translated_message, :translated_message_type, :by
  match do |record|
    date1 = 365.days.ago
    date2 = date1 + options.fetch(:by, 1.day)
    record.send("#{options[:field]}=", date1)
    record.send("#{options[:other_field]}=", date2)
    record.valid?
    result = record.errors[options[:field]].include?(options[:message]) if options.fetch(:message, nil).present?
    if options.fetch(:translated_message, nil).present? && result
      result = translation_match?(options)
    end
    result
  end

  def translation_match?(options)
    @translations ||= YAML.load_file("#{Rails.root}/config/locales/error_messages.en.yml") # lazy load translations
    message_type = options[:translated_message_type] || 'short'
    field = options[:field].to_s
    [
      @translations.has_key?(field),
      @translations[field].has_key?(options[:message]),
      @translations[field][options[:message]][message_type].eql?(options[:translated_message])
    ].all?
  end

  description do
    "error when earlier than #{options[:other_field]}#{" by #{options[:by]/86400} days" if options.fetch(:by, nil).present?}"
  end

  failure_message do |record|
    "expected #{record.errors.messages}} to include errors for #{options[:field]}"
  end

  failure_message_when_negated do |record|
    "expected #{record.errors.messages}} NOT to include errors for #{options[:field]}"
  end
end
