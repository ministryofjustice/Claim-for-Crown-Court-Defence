# frozen_string_literal: true

# Defines a rule to be applied to an object
# args:
# - attribute: the attribute of the object or a method chain
#   callable on the object
# - rule_method: name of the method to call against the
#   attrubte value
# - bound: the contraint to apply on the attribute value
#   using the rule_method
#
# options:
# - message: a custom message to add to attribute if
#   rule is violated.
# - attribute_for_error: the attribute to add an error
#   to if rule is violated (if different from attribute
#   specified above).
# - allow_nil: whether to consider a nil value a violation
#   or not. currently only applies to inclusion and exclusion
#   (see Rule::Method).
#

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
