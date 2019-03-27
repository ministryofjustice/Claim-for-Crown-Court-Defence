# Price: Wraps a fee calc API price object to
# factor in modifier effects and uplift parent
# quantities on fee_per_unit or fixed_fee
# attributes.
#
module Claims
  module FeeCalculator
    class ModifierDecorator < SimpleDelegator
      def fixed_percent?
        fixed_percent.to_f.nonzero?
      end

      def scale_factor
        return inverse_percentage(fixed_percent.to_f) / 100 if fixed_percent?
        percent_per_unit.to_f / 100
      end

      def ==(other)
        return super if other.class == self.class
        modifier_type.name.eql?(other.name.upcase.to_s) && limit_from.eql?(other.limit_from)
      end
      alias eql? ==

      private

      def inverse_percentage(percentage)
        return percentage if percentage.positive?
        100.00 + percentage
      end
    end
  end
end
