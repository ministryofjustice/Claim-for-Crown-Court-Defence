#
# class to manipulate various error key formats to
# a singuler format.
#
# Examples:
#  foo.bar -> foo_0_bar
#  foos.bar -> foo_0_bar
#  foos_attributes_0_bar -> foo_0_bar
#  foo_attributes_0_bar -> foo_0_bar
#
# TODO: extend support to cover rails indexed
# errors such as `foos[0].bar`.
#
module ErrorMessage
  module Helper
    extend ActiveSupport::Concern

    class_methods do
      # Support for keys in nested attribute format
      #
      # Examples:
      # fixed_fee.date_attended_1_date --> fixed_fee_0_date_attended_0_date
      # defendant.representation_order.maat_reference --> defendant_0_representation_order_0_maat_reference
      #
      def association_key(key)
        return key if key.to_s.index('.').blank?
        key.gsub('.', '_0_').gsub('_1_', '_0_')
      end
    end

    included do
      def association_key(key)
        self.class.association_key(key)
      end

      def numbered_model_regex
        /^(\S+?)(_(\d+)_)(\S+)$/
      end

      def unnumbered_model_regex
        /^(\S+?)\.(\S+)$/
      end

      def zero_based?(key)
        key.match?('_attributes') || key.match?(unnumbered_model_regex)
      end

      # Needed for GovUkDateField and Roles error handling (at least)
      # examples:
      # "Invalid date" --> invalid_date
      # "Choose at least one role" --> choose_at_least_one_role
      #
      def format_error(string)
        string.gsub(/\s+/, '_').downcase
      end

      def humanize_model_name(model_name)
        model_name.humanize.downcase.gsub(/misc fee/, 'miscellaneous fee')
      end

      def to_ordinal(number)
        int = number.to_i

        if int.zero?
          ''
        elsif int < 11
          to_ordinal_in_words(int)
        else
          int.ordinalize
        end
      end

      def to_ordinal_in_words(nth)
        %w[nil first second third fourth fifth sixth seventh eighth ninth tenth][nth]
      end
    end
  end
end
