# frozen_string_literal: true

module Fee
  module Concerns
    module FeeTypeRulesCreator
      extend ActiveSupport::Concern

      included do
        attr_reader :sets

        private

        def with_set_for_fee_type(unique_code)
          @sets ||= []
          fee_type = Fee::BaseFeeType.find_by(unique_code:)
          set = Rule::Set.new(fee_type)
          yield set
          @sets << set
        end

        def add_rule(*)
          Rule::Struct.new(*)
        end

        def graduated_fee_type_only_rule
          @graduated_fee_type_only_rule ||=
            ['claim.case_type_id',
             :inclusion,
             CaseType.trial_fees.ids,
             { message: 'case_type_inclusion',
               attribute_for_error: :fee_type,
               allow_nil: true }]
        end
      end

      class_methods do
        def all
          new.sets
        end

        def where(unique_code:)
          all.select { |rs| rs.object&.unique_code.eql?(unique_code) }
        end
      end
    end
  end
end
