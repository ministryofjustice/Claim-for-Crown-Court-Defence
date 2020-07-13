module Fee
  class FeeTypeRuleValidator
    attr_reader :fee, :rule_sets

    def initialize(fee, rule_sets)
      @fee = fee
      @rule_sets = rule_sets
    end

    def met?
      fee_rules&.map(&:met?)&.all?
    end
    alias validate met?

    private

    def fee_rules
      return @fee_rules if @fee_rules.present?

      @fee_rules = rule_sets.each_with_object([]) do |rule_set, arr|
        rule_set.each do |rule|
          arr << Rule::Applicator.new(fee, rule)
        end
      end
    end
  end
end
