# frozen_string_literal: true

module Fee
  module LGFS
    class FeeTypeRules
      include Fee::Concerns::FeeTypeRulesCreator

      def initialize
        with_set_for_fee_type('MIUMU') do |set|
          set << add_rule(*graduated_fee_type_only_rule)
          set << add_rule(*clar_fee_type_only_rule)
        end

        with_set_for_fee_type('MIUMO') do |set|
          set << add_rule(*graduated_fee_type_only_rule)
          set << add_rule(*clar_fee_type_only_rule)
        end
      end

      private

      # FIXME: Settings.clar_release_date requires `to_date` here when called
      # by app via page load but not anywhere else, like tests - why?!
      def clar_fee_type_only_rule
        @clar_fee_type_only_rule ||=
          [
            'claim.earliest_representation_order_date',
            :minimum,
            Settings.clar_release_date.to_date.beginning_of_day,
            { message: 'fee_scheme_applicability',
              attribute_for_error: :fee_type,
              allow_nil: true }
          ]
      end
    end
  end
end
