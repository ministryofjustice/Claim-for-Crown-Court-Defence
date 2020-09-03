# frozen_string_literal: true

module Rule
  class Struct
    attr_reader :attribute, :rule_method, :bound, :message, :options

    def initialize(attribute, rule_method, bound, message, options = {})
      @attribute = attribute
      @rule_method = rule_method
      @bound = bound
      @message = message
      @options = options
    end
  end
end
