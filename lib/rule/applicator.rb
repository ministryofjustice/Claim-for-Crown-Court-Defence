# frozen_string_literal: true

module Rule
  class Applicator
    attr_reader :object, :rule

    def initialize(object, rule)
      @object = object
      @rule = rule
    end

    def met?
      met = rule_for_object.met?
      add_error unless met
      met
    end

    private

    def rule_for_object
      @rule_for_object ||= Rule::Method.new(rule.rule_method,
                                            rule_attribute_value,
                                            rule.bound,
                                            rule.options)
    end

    def rule_attribute_value
      rule_attribute.inject(object) { |product, method| product&.send(method) }
    end

    def rule_attribute
      @rule_attribute ||= Rule::AttributeParser.new(rule.attribute).call
    end

    def add_error
      object.errors.add(rule_attribute_for_error, rule.message)
    end

    def rule_attribute_for_error
      return rule.options[:attribute_for_error] if rule.options[:attribute_for_error]
      rule_attribute.join('.')
    end
  end
end
