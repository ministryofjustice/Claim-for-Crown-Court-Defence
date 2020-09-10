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
    end

    def unmet?
      !met?
    end

    def maximum
      return true if nil_src_allowed?
      src <= bound
    end
    alias max maximum

    def minimum
      return true if nil_src_allowed?
      src >= bound
    end
    alias min minimum

    def equal
      return true if nil_src_allowed?
      src == bound
    end

    def inclusion
      return true if nil_src_allowed?
      bound.include?(src)
    end

    def exclusion
      return options[:allow_nil] if src.nil? && !options[:allow_nil].nil?
      !bound.include?(src)
    end

    private

    def nil_src_allowed?
      options[:allow_nil] && src.nil?
    end
  end
end
