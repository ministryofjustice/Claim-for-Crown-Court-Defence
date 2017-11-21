# This is a work in progress, aiming to provide all
# data possible to enable successful injection
# of a claim into CCR.
#
module API
  module Entities
    class CCRClaim < BaseEntity
      expose :uuid
      expose :supplier_number
      expose :case_number
      expose  :first_day_of_trial,
              :trial_fixed_notice_at,
              :trial_fixed_at,
              :trial_cracked_at,
              :last_submitted_at,
              format_with: :utc
      expose :trial_cracked_at_third

      expose :case_type, using: API::Entities::CCR::CaseType
      expose :court, using: API::Entities::CCR::Court
      expose :offence, using: API::Entities::CCR::Offence
      expose :defendants_with_main_first, using: API::Entities::CCR::Defendant, as: :defendants

      # CCR fields that can be derived from CCCD data
      expose :estimated_trial_length_or_one, as: :estimated_trial_length, format_with: :string
      expose :actual_trial_length_or_one, as: :actual_trial_Length, format_with: :string

      # CCR fields whose values can, and are, mapped to a CCCD field's values
      expose :adapted_advocate_category, as: :advocate_category

      # CCR fee to bill mappings
      expose :bills

      private

      def defendants_with_main_first
        object.defendants.order(created_at: :asc)
      end

      def estimated_trial_length_or_one
        [object.estimated_trial_length, 1].compact.max
      end

      def actual_trial_length_or_one
        [object.actual_trial_length, 1].compact.max
      end

      def bills
        data = []
        data.push API::Entities::CCR::AdaptedBasicFee.represent(basic_fees)
        data.push API::Entities::CCR::AdaptedFixedFee.represent(fixed_fees)
        data.push API::Entities::CCR::AdaptedMiscFee.represent(miscellaneous_fees)
        data.flatten.as_json
      end

      def adapted_advocate_category
        ::CCR::AdvocateCategoryAdapter.code_for(object.advocate_category) if object.advocate_category.present?
      end

      def basic_fee_adapter
        ::CCR::Fee::BasicFeeAdapter.new
      end

      def basic_fees
        fee = basic_fee_adapter.call(object)
        [].tap do |arr|
          arr << fee if fee.claimed?
        end
      end

      def fixed_fee_adapter
        ::CCR::Fee::FixedFeeAdapter.new
      end

      def fixed_fees
        fee = fixed_fee_adapter.call(object)
        [].tap do |arr|
          arr << fee if fee.claimed?
        end
      end

      def misc_fee_adapter
        ::CCR::Fee::MiscFeeAdapter.new
      end

      # CCR miscellaneous fees cover CCCD basic, fixed and miscellaneous fees
      #
      def miscellaneous_fees
        object.fees.each_with_object([]) do |fee, memo|
          misc_fee_adapter.call(fee).tap do |f|
            memo << f if f.claimed?
          end
        end
      end
    end
  end
end
