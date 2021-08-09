# frozen_string_literal: true

module ErrorMessage
  class Key < String
    include ErrorMessage::Helper

    def initialize(key)
      super key.to_s
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

    private

    def details
      @details ||= parse
    end

    def parse
      attribute = association_key(self)
      all_model_indices = {}

      while attribute.match(numbered_model_regex)
        model = Regexp.last_match(1)
        model.slice!('_attributes')
        model = model.singularize
        all_model_indices[model] = Regexp.last_match(3)
        attribute = Regexp.last_match(4)
      end

      { model: model, attribute: attribute, all_model_indices: all_model_indices }
    end
  end
end
