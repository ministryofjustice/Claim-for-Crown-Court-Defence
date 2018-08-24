# Price: Wraps a fee calc API price object to
# factor in modifier effects and uplift parent quantities
# on fee per unit.
#
module Claims
  module FeeCalculator
    class Price
      attr_reader :price, :modifier_name, :parent_quantity

      def initialize(price, modifier_name = nil, parent_quantity = 1)
        @price = price
        @modifier_name = modifier_name
        @parent_quantity = parent_quantity
      end

      def fee_per_unit
        price.fee_per_unit.to_f * modifier_scale_factor * parent_quantity
      end

      def modifier
        return nil unless modifier_name

        @modifier ||= price.modifiers.find do |m|
          m.modifier_type.name.eql?(modifier_name.upcase.to_s)
        end

        raise 'Modifier not found' unless @modifier
        @modifier
      end

      private

      def modifier_scale_factor
        return 1 unless modifier
        modifier.percent_per_unit.to_f / 100
      end
    end
  end
end
