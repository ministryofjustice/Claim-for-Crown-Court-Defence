require 'rspec/expectations'

RSpec::Matchers.define :include_field_error_when do |options|
  options.assert_valid_keys :field, :other_field, :field_value, :other_field_value, :message, :translated_message, :translated_message_type
  match do |record|
    @options = options
    record.send("#{field}=", options[:field_value])
    record.send("#{other_field}=", options[:other_field_value])
    record.valid?
    result = record.errors[field].include?(message) if message.present?
    result = translation_match? if result && translated_message.present?
    result
  end

  def options
    @options
  end

  def translation_match?
    [
      translations.has_key?(field),
      translations[field].has_key?(message),
      actual_translated_message.eql?(translated_message)
    ].all?
  end

  def actual_translated_message
    translations.fetch(field, nil)&.fetch(message, nil)&.fetch(translated_message_type, nil)
  end

  def translations
    @translations ||= YAML.load_file("#{Rails.root}/config/locales/error_messages.en.yml") # lazy load translations
  end

  def translated_message_type
    @message_type ||= options[:translated_message_type] || 'short'
  end

  def field
    @field ||= options[:field].to_s
  end

  def other_field
    @other_field ||= options[:other_field].to_s
  end

  def message
    @message ||= options.fetch(:message, nil)
  end

  def translated_message
    @translated_message ||= options.fetch(:translated_message, nil)
  end

  description do
    "include error #{message} on #{field}"
  end

  failure_message do |record|
    msg = ''
    msg += "expected valid: false\n got: true\n " if record.valid?
    msg += "expected error: #{message} on #{field}\n got: #{record.errors[field]}\n" if message.present? && !record.errors[field].include?(message)
    msg += "expected #{translated_message_type + ' '}translation: \"#{translated_message}\"\n got: \"#{actual_translated_message}\"" if translated_message.present? && !actual_translated_message.eql?(translated_message)
    msg
  end

  failure_message_when_negated do |record|
    "expected #{record.errors.messages}} NOT to include errors for #{options[:field]}"
  end
end
