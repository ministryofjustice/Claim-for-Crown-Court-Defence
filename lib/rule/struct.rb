# frozen_string_literal: true

module Rule
  class Struct
    attr_reader :attribute, :rule_method, :bound, :options

    def initialize(attribute, rule_method, bound, options = {})
      @attribute = attribute
      @rule_method = rule_method
      @bound = bound
      @options = options
    end

    def message
      options[:message] || "#{attribute} is invalid"
    end
  end
end
