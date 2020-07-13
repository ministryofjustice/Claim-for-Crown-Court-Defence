# frozen_string_literal: true

module Rule
  class Struct
    attr_reader :attribute, :rule_method, :bound, :message

    def initialize(attribute, rule_method, bound, message)
      @attribute = attribute
      @rule_method = rule_method
      @bound = bound
      @message = message
    end
  end
end
