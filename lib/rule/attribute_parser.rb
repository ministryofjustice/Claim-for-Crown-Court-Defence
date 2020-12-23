# frozen_string_literal: true

module Rule
  class AttributeParser
    attr_reader :attribute

    def initialize(attribute)
      @attribute = attribute
    end

    def call
      return parse_from_array if attribute.is_a?(Array)
      parse_symbol_or_string
    end

    private

    def parse_symbol_or_string
      return [attribute].flatten if attribute.is_a?(Symbol)
      attribute.split('.').map(&:to_sym)
    end

    def parse_from_array
      attribute.map(&:to_sym)
    end
  end
end
