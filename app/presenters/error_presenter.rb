class ErrorPresenter
  SUBMODEL_REGEX = /^(\S+?)(_(\d+)_)(\S+)$/.freeze

  def initialize(claim, message_file = nil)
    @claim = claim
    @errors = claim.errors
    message_file ||= "#{Rails.root}/config/locales/error_messages.#{I18n.locale}.yml"
    @translations = YAML.load_file(message_file)
    @error_details = ErrorDetailCollection.new
    generate_messages
  end

  def errors_for?(fieldname)
    @error_details.errors_for?(fieldname)
  end

  def field_level_error_for(fieldname)
    @error_details.short_messages_for(fieldname)
  end

  def header_errors
    @error_details.header_errors
  end

  def size
    @error_details.size
  end

  private

  def generate_messages
    @errors.each do |error|
      emt = ErrorMessageTranslator.new(@translations, error.attribute, error.message)
      messages = populate_messages(emt, error.message, error.attribute)
      next if @error_details[error.attribute] && @error_details[error.attribute][0].long_message.eql?(messages.long)
      @error_details[error.attribute] = ErrorDetail.new(
        error.attribute,
        messages.long,
        messages.short,
        messages.api,
        generate_sequence(error.attribute)
      )
    end
  end

  def populate_messages(emt, error, field_name)
    message = Struct.new(:long, :short, :api).new
    if emt.translation_found?
      message.long = emt.long_message
      message.short = emt.short_message
      message.api = emt.api_message
    else
      message.long = generate_standard_long_message(field_name, error)
      message.short = generate_standard_short_message(field_name, error)
      message.api = generate_standard_api_message(field_name, error)
    end
    message
  end

  def last_parent_attribute(_translations, key)
    attribute = ErrorMessageTranslator.association_key(key)
    while attribute =~ SUBMODEL_REGEX
      parent_model = Regexp.last_match(1)
      attribute = Regexp.last_match(4)
    end
    [parent_model, attribute]
  end

  def is_submodel_key?(key)
    key =~ SUBMODEL_REGEX
  end

  def translations_sub_set_and_parent_sequence(key)
    key = key.to_s
    parent_sequence = 0
    if is_submodel_key?(key)
      parent_model, attribute = last_parent_attribute(@translations, key)
      parent_sequence = @translations.dig(parent_model, '_seq') || 0
      translations_subset = @translations.dig(parent_model, attribute)
    else
      translations_subset = @translations[key]
    end

    [translations_subset, parent_sequence]
  end

  # NOTE:
  # sequence = (attribute's _seq value + parent's _seq value) or parents _seq or 99999
  #
  def generate_sequence(key)
    translations_subset, parent_sequence = translations_sub_set_and_parent_sequence(key)
    begin
      translations_subset['_seq'].present? ? translations_subset['_seq'] + parent_sequence : parent_sequence || 99_999
    rescue StandardError
      99_999
    end
  end

  def generate_link(fieldname)
    '#' + fieldname
  end

  def generate_standard_long_message(fieldname, error)
    "#{fieldname.to_s.humanize} #{error.humanize.downcase}"
  end

  def generate_standard_short_message(_fieldname, error)
    error.humanize
  end

  def generate_standard_api_message(fieldname, error)
    "#{fieldname.to_s.humanize} #{error.humanize.downcase}"
  end
end
