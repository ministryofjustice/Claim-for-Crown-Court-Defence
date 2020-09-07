# frozen_string_literal: true

module Rule
  class Method
    attr_reader :rule_method, :src, :bound, :options

    def initialize(rule_method, src, bound, options = {})
      @rule_method = rule_method
      @src = src
      @bound = bound
      @options = options
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

    def inclusion
      return true if options[:allow_nil] && src.nil?
      bound.include?(src)
    end

    def exclusion
      return options[:allow_nil] if src.nil? && !options[:allow_nil].nil?
      !bound.include?(src)
    end
  end
end
