module Rule
  class Validator
    attr_reader :object, :rule_sets

    def initialize(object, rule_sets)
      @object = object
      @rule_sets = rule_sets
    end

    def met?
      object_rules&.map(&:met?)&.all?
    end
    alias validate met?

    private

    def object_rules
      return @object_rules if @object_rules.present?

      @object_rules = rule_sets.each_with_object([]) do |rule_set, arr|
        rule_set.each do |rule|
          arr << Rule::Applicator.new(object, rule)
        end
      end
    end
  end
end
