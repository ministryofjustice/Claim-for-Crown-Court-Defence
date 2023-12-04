# frozen_string_literal: true

module ErrorMessage
  class Key < String
    def initialize(key)
      super(key.to_s)
    end

    def zero_based?
      match?('_attributes') || match?(unnumbered_model_regex)
    end

    def submodel?
      numbered_submodel? || unnumbered_submodel?
    end

    def numbered_submodel?
      match?(numbered_model_regex)
    end

    def unnumbered_submodel?
      match?(unnumbered_model_regex)
    end

    def model
      details[:model]
    end

    def attribute
      details[:attribute]
    end

    def all_model_indices
      details[:all_model_indices]
    end

    # Support for keys in nested attribute format
    #
    # Examples:
    # fixed_fee.date_attended_1_date --> fixed_fee_0_date_attended_0_date
    # defendant.representation_order.maat_reference --> defendant_0_representation_order_0_maat_reference
    #
    def association_key
      return self unless include?('.')
      gsub('.', '_0_').gsub('_1_', '_0_')
    end

    private

    def details
      @details ||= parse
    end

    def parse
      attribute = association_key
      all_model_indices = {}

      while attribute.match(numbered_model_regex)
        model = Regexp.last_match(1)
        model.slice!('_attributes')
        model = model.singularize
        all_model_indices[model] = Regexp.last_match(3)
        attribute = Key.new(Regexp.last_match(4))
      end

      { model:, attribute:, all_model_indices: }
    end

    def numbered_model_regex
      /^(\S+?)(_(\d+)_)(\S+)$/
    end

    def unnumbered_model_regex
      /^(\S+?)\.(\S+)$/
    end
  end
end
