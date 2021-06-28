# This class is reponsible for translating messages, including nested submodel messages with keys
# like :defendant_3_represntation_order_2_date_of_birth

class ErrorMessageTranslator
  def initialize(translations, fieldname, error)
    @translations     = translations
    @key              = fieldname.to_s
    @error            = error
    @submodel_numbers = {}
    @regex            = /^(\S+?)(_(\d+)_)(\S+)$/
    @submodel_regex   = /^(\S+?)\.(\S+)$/
  end

  # Support for keys in the format: fixed_fee.date_attended_1_date
  # Will convert it to: fixed_fee_0_date_attended_0_date
  #
  def self.association_key(key)
    return key if key.index('.').blank?
    key.sub('.', '_0_').sub('_1_', '_0_')
  end

  def long_message
    @long_message ||= substitute_submodel_numbers_and_names(all_messages[:long_message]) || "#{@key.to_s.humanize} #{@error.humanize.downcase}"
  end

  def short_message
    @short_message ||= substitute_submodel_numbers_and_names(all_messages[:short_message]) || @error.humanize
  end

  def api_message
    @api_message ||= substitute_submodel_numbers_and_names(all_messages[:api_message]) || "#{@key.to_s.humanize} #{@error.humanize.downcase}"
  end

  private

  def all_messages
    @all_messages ||= get_messages(@translations, @key, @error) || {}
  end

  # needed for GovUkDateField error handling (at least)
  def format_error(error)
    error.gsub(/\s+/, '_').downcase
  end

  def get_messages(translations, key, error)
    error = format_error(error)

    if key_refers_to_numbered_submodel?(key) && submodel_key_exists?(translations, key)
      translation_subset, submodel_key = extract_last_submodel_attribute(translations, key)
      get_messages(translation_subset, submodel_key, error)
    elsif key_refers_to_unnumbered_submodel?(key)
      translation_subset, submodel_key = extract_submodel_attribute(translations, key)
      get_messages(translation_subset, submodel_key, error)
    elsif translation_exists?(translations, key, error)
      {
        long_message: translations[key][error]['long'],
        short_message: translations[key][error]['short'],
        api_message: translations[key][error]['api']
      }
    end
  end

  def submodel_key_exists?(translations, key)
    parent_model, = last_parent_attribute(translations, key)
    !translations[parent_model].nil?
  end

  def key_refers_to_numbered_submodel?(key)
    key =~ @regex
  end

  def key_refers_to_unnumbered_submodel?(key)
    key =~ @submodel_regex
  end

  def last_parent_attribute(_translations, key)
    attribute = self.class.association_key(key)
    while attribute =~ @regex
      parent_model = Regexp.last_match(1)
      submodel_id  = Regexp.last_match(3)
      attribute = Regexp.last_match(4)

      # store each submodel instance number against parent model too
      @submodel_numbers[parent_model] = submodel_id
    end
    [parent_model, attribute]
  end

  def extract_last_submodel_attribute(translations, key)
    parent_model, attribute = last_parent_attribute(translations, key)
    translation_subset = translations.fetch(parent_model, {})
    [translation_subset, attribute]
  end

  def extract_submodel_attribute(translations, key)
    key =~ @submodel_regex
    parent_model = Regexp.last_match(1)
    attribute = Regexp.last_match(2)
    @submodel_numbers[parent_model] = 0
    translation_subset = translations.fetch(parent_model, {})
    [translation_subset, attribute]
  end

  def humanize_submodel_name(submodel_name)
    submodel_name.humanize.downcase.gsub(/misc fee/, 'miscellaneous fee')
  end

  def substitute_submodel_numbers_and_names(message)
    return if message.nil?

    @submodel_numbers.each do |submodel_name, number|
      substitution_key = '#{' + submodel_name + '}'
      substitution_value = [to_ordinal(number), humanize_submodel_name(submodel_name)].select(&:present?).join(' ')
      message = message.sub(substitution_key, substitution_value)
    end
    # clean out unused message substitution keys
    message = message.gsub(/#\{(\S+)\}/, '')
    message
  end

  def translation_exists?(translations, key, error)
    translations.key?(key) && translations[key][error].present?
  end

  def to_ordinal(number)
    n = number.to_i
    if n.zero?
      ''
    elsif n < 11
      to_ordinal_in_words(n)
    else
      n.ordinalize
    end
  end

  def to_ordinal_in_words(nth)
    %w[nil first second third fourth fifth sixth seventh eighth ninth tenth][nth]
  end
end
