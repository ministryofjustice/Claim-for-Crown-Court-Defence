# frozen_string_literal: true

module Fee
  module Agfs
    class FeeTypeRules
      include Fee::Concerns::FeeTypeRulesCreator

      def initialize
        with_set_for_fee_type('MIUMU') do |set|
          set << add_rule(:quantity, :equal, 1, message: :miumu_numericality)
          set << add_rule(*graduated_fee_type_only_rule)
        end

        with_set_for_fee_type('MIUMO') do |set|
          set << add_rule(*graduated_fee_type_only_rule)
        end

        with_set_for_fee_type('MIPHC') do |set|
          set << add_rule('claim.offence.offence_band.offence_category.number',
                          :exclusion,
                          [1, 6, 9],
                          message: :offence_category_exclusion,
                          attribute_for_error: :fee_type)
        end
      end
    end
  end
end
