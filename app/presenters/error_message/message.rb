#
# Class to represent a single custom error message with
# its variants of long, short and api.
#
module ErrorMessage
  class Message
    def initialize(long, short, api, key)
      @long = long
      @short = short
      @api = api
      @key = key
    end

    def long
      substitute_submodel_numbers_and_names(@long)
    end

    def short
      substitute_submodel_numbers_and_names(@short)
    end

    def api
      substitute_submodel_numbers_and_names(@api)
    end

    private

    def substitute_submodel_numbers_and_names(message)
      @key.all_model_indices.each do |model_name, number|
        int = number.to_i
        int += 1 if @key.zero_based?
        substitution_key = '#{' + model_name + '}'
        substitution_value = [to_ordinal(int), humanize_model_name(model_name)].compact_blank.join(' ')
        message = message.sub(substitution_key, substitution_value)
      end

      # clean out unused message substitution keys
      message&.gsub(/#\{(\S+)\}/, '')
    end

    def humanize_model_name(model_name)
      model_name.humanize.downcase.gsub('misc fee', 'miscellaneous fee')
    end

    def to_ordinal(number)
      int = number.to_i

      if int.zero?
        ''
      elsif int < 11
        to_ordinal_in_words(int)
      else
        int.ordinalize
      end
    end

    def to_ordinal_in_words(nth)
      %w[nil first second third fourth fifth sixth seventh eighth ninth tenth][nth]
    end
  end
end
