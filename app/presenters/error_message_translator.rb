# This class is reponsible for translating messages, including nested submodel messages with keys
# like :defendant_3_represntation_order_2_date_of_birth

class ErrorMessageTranslator

  attr_reader :long_message, :short_message

  def initialize(translations, fieldname, error)
    @translations     = translations
    @key              = fieldname.to_s
    @error            = error
    @submodel_numbers = {}
    @long_message     = nil
    @short_message    = nil
    @regex            = /^(\S+?)(_(\d+)_)(\S+)$/
    translate!
  end


  def translate!
    get_messages(@translations, @key, @error)
    if translation_found?
      @long_message = substitute_submodel_numbers(@long_message)
      @short_message = substitute_submodel_numbers(@short_message)
    end
  end

  def translation_found?
    !translation_not_found?
  end

  def translation_not_found?
    @long_message.nil? || @short_message.nil?
  end


  private

  def get_messages(translations, key, error)
    if key_refers_to_numbered_submodel?(key)  && submodel_key_exists?(translations, key)
      translation_subset, submodel_key = extract_submodel_and_key(translations, key)
      get_messages(translation_subset, submodel_key, error)
    else
      if translation_exists?(translations, key, error)
        @long_message  = translations[key][error]['long']
        @short_message = translations[key][error]['short']
      end
    end
  end


  def submodel_key_exists?(translations, key)
    key =~ @regex
    parent_model = $1
    translations[parent_model].nil? ? false : true
  end


  def key_refers_to_numbered_submodel?(key)
    key =~ @regex
  end

  def extract_submodel_and_key(translations, key)
    key =~ @regex
    parent_model = $1
    submodel_id  = $3
    submodel_key = $4
    @submodel_numbers[parent_model] = submodel_id
    translation_subset = translations[parent_model]
    [translation_subset, submodel_key]
  end


  def substitute_submodel_numbers(message)
    @submodel_numbers.each do |submodel_name, number|
      substitution_key = '#{' + submodel_name + '}'
      message = message.sub(substitution_key, to_ordinal(number))
    end
    message
  end

  def translation_exists?(translations, key, error)
    if translations[key]
      if translations[key][error]
        return true
      end
    end
    return false
  end

  def to_ordinal(number)
    n = number.to_i
    if n < 11
      to_ordinal_in_words(n)
    else
      n.ordinalize
    end
  end

  def to_ordinal_in_words(n)
    ordinals = %w{ first second third fourth fifth sixth seventh eighth ninth tenth }
    ordinals[n-1]
  end

end