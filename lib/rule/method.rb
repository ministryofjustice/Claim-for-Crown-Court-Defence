# frozen_string_literal: true

module Rule
  class Method
    attr_reader :rule_method, :src, :bound

    def initialize(rule_method, src, bound)
      @rule_method = rule_method
      @src = src
      @bound = bound
    end

    def met?
      send(rule_method)
    rescue NoMethodError => e
      raise e, "you need to implement rule method '#{rule_method}'"
    end

    def unmet?
      !met?
    end

    def maximum
      src <= bound
    end
    alias max maximum

    def minimum
      src >= bound
    end
    alias min minimum

    def equal
      src == bound
    end
  end
end
