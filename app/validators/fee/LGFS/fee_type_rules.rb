# frozen_string_literal: true

module Fee
  module LGFS
    class FeeTypeRules
      include Fee::Concerns::FeeTypeRulesCreator

      def initialize
        with_set_for_fee_type('MIUMU') do |set|
          set << add_rule(*graduated_fee_type_only_rule)
        end

        with_set_for_fee_type('MIUMO') do |set|
          set << add_rule(*graduated_fee_type_only_rule)
        end
      end
    end
  end
end
