require 'rspec/expectations'

RSpec::Matchers.define :include_field_error_when do |options|
  options.assert_valid_keys :field, :other_field, :field_value, :other_field_value, :message, :translated_message,
                            :translated_message_type

  match do |record|
    @options = options
    record.send(:"#{field}=", @options[:field_value])
    record.send(:"#{other_field}=", @options[:other_field_value])
    record.valid?
    result = record.errors[field].include?(message) if message.present?
    result = translation_match? if result && translated_message.present?
    result
  end

  def translation_match?
    [
      translations.key?(field),
      translations[field].key?(message),
      actual_translated_message.eql?(translated_message)
    ].all?
  end

  def actual_translated_message
    translations.dig(field, message, translated_message_type)
  end

  def translations
    @translations ||= YAML.load_file(translations_file, aliases: true) # lazy load translations
  end

  def translations_file
    ErrorMessage.default_translation_file
  end

  def translated_message_type
    @translated_message_type ||= @options[:translated_message_type] || 'short'
  end

  def field
    @field ||= @options[:field].to_s
  end

  def other_field
    @other_field ||= @options[:other_field].to_s
  end

  def message
    @message ||= @options.fetch(:message, nil)
  end

  def translated_message
    @translated_message ||= @options.fetch(:translated_message, nil)
  end

  description do
    "include error #{message} on #{field}"
  end

  failure_message do |record|
    msg = ''
    msg += "expected valid: false\n got: true\n " if record.valid?
    if message.present? && record.errors[field].exclude?(message)
      msg += "expected error: #{message} on #{field}\n got: #{record.errors[field]}\n"
    end
    if translated_message.present? && !actual_translated_message.eql?(translated_message)
      msg += "expected #{translated_message_type + ' '}translation: \"#{translated_message}\"\n got: \"#{actual_translated_message}\""
    end
    msg
  end

  failure_message_when_negated do |record|
    "expected #{record.errors.messages}} NOT to include errors for #{@options[:field]}"
  end
end
