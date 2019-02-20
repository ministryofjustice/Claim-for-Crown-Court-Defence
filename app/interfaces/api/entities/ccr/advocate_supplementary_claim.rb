module API
  module Entities
    module CCR
      class AdvocateSupplementaryClaim < BaseEntity
        expose :uuid
        expose :supplier_number
        expose :case_number
        expose :last_submitted_at, format_with: :utc

        expose :adapted_advocate_category, as: :advocate_category
        expose :dummy_case_type, as: :case_type, using: API::Entities::CCR::CaseType
        expose :court, using: API::Entities::CCR::Court
        expose :defendants_with_main_first, using: API::Entities::CCR::Defendant, as: :defendants

        with_options(format_with: :string) do
          expose :actual_trial_length_or_one, as: :actual_trial_Length
          expose :estimated_trial_length_or_one, as: :estimated_trial_length
          expose :retrial_actual_length_or_one, as: :retrial_actual_length
          expose :retrial_estimated_length_or_one, as: :retrial_estimated_length
        end

        expose :additional_information

        expose :bills

        private

        # TODO: promote to a CCR::BasClaim entity?
        def defendants_with_main_first
          object.defendants.order(created_at: :asc)
        end

        # TODO: promote to a CCR::BasClaim entity?
        def estimated_trial_length_or_one
          object.estimated_trial_length.or_one
        end

        # TODO: promote to a CCR::BasClaim entity?
        def actual_trial_length_or_one
          object.actual_trial_length.or_one
        end

        # TODO: promote to a CCR::BasClaim entity?
        def retrial_actual_length_or_one
          object.retrial_actual_length.or_one
        end

        # TODO: promote to a CCR::BasClaim entity?
        def retrial_estimated_length_or_one
          object.retrial_estimated_length.or_one
        end

        # FIXME: dummy a guilty plea for injection purposes as CCR requires a bill scenario regardless
        # TODO:
        def dummy_case_type
          ::CaseType.find_by(name: 'Guilty plea')
        end

        def misc_fee_adapter
          ::CCR::Fee::MiscFeeAdapter.new
        end

        # CCR miscellaneous fees cover CCCD basic, fixed and miscellaneous fees
        # for supplementary claims we are currently only including types that are
        # miscellaneous (in CCCD)
        # NOTE: uplifts are not claimed
        def miscellaneous_fees
          object.misc_fees.each_with_object([]) do |fee, memo|
            misc_fee_adapter.call(fee).tap do |f|
              memo << f if f.claimed?
            end
          end
        end

        # TODO: try to get the adapter component into the adapted_misc_fee entity
        #
        def bills
          data = []
          data.push AdaptedMiscFee.represent(miscellaneous_fees)
          data.push AdaptedExpense.represent(object.expenses)
          data.flatten.as_json
        end

        def adapted_advocate_category
          ::CCR::AdvocateCategoryAdapter.code_for(object.advocate_category) if object.advocate_category.present?
        end
      end
    end
  end
end
