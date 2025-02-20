# Wraps a fee calc API price object to
# factor in modifier effects and uplift parent
# quantities on fee_per_unit or fixed_fee
# attributes.
#
module Claims
  module FeeCalculator
    # OPTIMIZE: rename to PriceDecorator? and subclass to Delegator class?
    class Price
      attr_reader :price, :unit_modifiers, :parent_quantity

      def initialize(price, unit_modifiers = [], parent_quantity = 1)
        @price = price
        @unit_modifiers = unit_modifiers
        @parent_quantity = parent_quantity
      end

      def per_unit
        fee = fixed_fee? ? fixed_fee : fee_per_unit
        fee.round(2)
      end

      def unit
        return uplift_modifier_name if uplift_modifier?
        price.unit
      end

      def modifiers
        @modifiers ||= price.modifiers.each_with_object([]) do |modifier, arr|
          modifier = ModifierDecorator.new(modifier)
          arr.append(modifier) if unit_modifiers.any? { |unit_modifier| modifier == unit_modifier }
        end
      end

      UPLIFT_MODIFIERS = %i[number_of_defendants number_of_cases].freeze
      private_constant :UPLIFT_MODIFIERS

      private

      def fee_per_unit
        @fee_per_unit ||= apply_modifiers(price.fee_per_unit.to_f) * parent_quantity
      end

      def fixed_fee
        @fixed_fee ||= apply_modifiers(price.fixed_fee.to_f)
      end

      def apply_modifiers(amount)
        modifiers.reduce(amount) do |product, modifier|
          product * modifier.scale_factor
        end
      end

      def fixed_fee?
        price.fixed_fee.to_f.nonzero?
      end

      def uplift_modifier?
        unit_modifiers.map(&:name).intersect?(UPLIFT_MODIFIERS)
      end

      def uplift_modifier_name
        uplift_modifier = unit_modifiers.find { |um| UPLIFT_MODIFIERS.include?(um.name) }
        uplift_modifier.name.upcase.to_s.singularize.sub('NUMBER_OF_', '')
      end
    end
  end
end
