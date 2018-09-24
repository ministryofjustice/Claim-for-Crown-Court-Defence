require 'rspec/expectations'

RSpec::Matchers.define :include_field_error_when do |options|
  options.assert_valid_keys :field, :other_field, :field_value, :other_field_value, :message, :translated_message, :translated_message_type
  match do |record|
    record.send("#{options[:field]}=", options[:field_value])
    record.send("#{options[:other_field]}=", options[:other_field_value])
    record.valid?
    result = record.errors[options[:field]].include?(options[:message]) if options.fetch(:message, nil).present?
    result = translation_match?(options) if result && options.fetch(:translated_message, nil).present?
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
    "include error on #{options[:field]} when #{options[:field]}: #{options[:field_value]} and #{options[:other_field]}: #{options[:other_field_value]}"
  end

  failure_message do |record|
    "expected #{record.errors.messages}} to include errors for #{options[:field]}"
  end

  failure_message_when_negated do |record|
    "expected #{record.errors.messages}} NOT to include errors for #{options[:field]}"
  end
end
