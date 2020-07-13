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
      @rule_for_object ||= Rule::Method.new(rule.rule_method, object.send(rule.attribute), rule.bound)
    end

    def add_error
      object.errors.add(rule.attribute.to_sym, rule.message)
    end
  end
end
