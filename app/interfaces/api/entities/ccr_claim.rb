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
              :retrial_started_at,
              :last_submitted_at,
              format_with: :utc
      expose :trial_cracked_at_third

      expose :adapted_advocate_category, as: :advocate_category
      expose :case_type, using: API::Entities::CCR::CaseType
      expose :court, using: API::Entities::CCR::Court
      expose :offence, using: API::Entities::CCR::Offence
      expose :defendants_with_main_first, using: API::Entities::CCR::Defendant, as: :defendants

      # TODO: need a new field for retrial reductions
      expose :dummy_retrial_reduction, as: :retrial_reduction

      with_options(format_with: :string) do
        expose :actual_trial_length_or_one, as: :actual_trial_Length
        expose :estimated_trial_length_or_one, as: :estimated_trial_length
        expose :retrial_actual_length_or_one, as: :retrial_actual_length
        expose :retrial_estimated_length_or_one, as: :retrial_estimated_length
      end

      expose :additional_information

      # CCR fees and expenses to bill mappings
      expose :bills

      private

      def defendants_with_main_first
        object.defendants.order(created_at: :asc)
      end

      def dummy_retrial_reduction
        true
      end

      def estimated_trial_length_or_one
        object.estimated_trial_length.or_one
      end

      def actual_trial_length_or_one
        object.actual_trial_length.or_one
      end

      def retrial_actual_length_or_one
        object.retrial_actual_length.or_one
      end

      def retrial_estimated_length_or_one
        object.retrial_actual_length.or_one
      end

      def bills
        data = []
        data.push API::Entities::CCR::AdaptedBasicFee.represent(basic_fees)
        data.push API::Entities::CCR::AdaptedFixedFee.represent(fixed_fees)
        data.push API::Entities::CCR::AdaptedMiscFee.represent(miscellaneous_fees)
        data.push API::Entities::CCR::AdaptedExpense.represent(object.expenses)
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
