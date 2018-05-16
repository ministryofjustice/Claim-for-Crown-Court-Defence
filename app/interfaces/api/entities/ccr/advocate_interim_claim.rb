module API
  module Entities
    module CCR
      class AdvocateInterimClaim < BaseEntity
        expose :uuid
        expose :supplier_number
        expose :case_number
        expose :last_submitted_at, format_with: :utc

        expose :adapted_advocate_category, as: :advocate_category
        expose :dummy_case_type, as: :case_type, using: API::Entities::CCR::CaseType
        expose :court, using: API::Entities::CCR::Court
        expose :offence, using: API::Entities::CCR::Offence
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

        def defendants_with_main_first
          object.defendants.order(created_at: :asc)
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
          object.retrial_estimated_length.or_one
        end

        # FIXME: dummy a guilty plea for injection purposes as CCR requires a bill scenario regardless
        # NOTE: In CCR, all case types have the same claimable value/fee for a warrant fee
        # (all else being equal) except Discontinuance case types that have half the value.
        #
        def dummy_case_type
          ::CaseType.find_by(name: 'Guilty plea')
        end

        def bills
          data = []
          data.push AdaptedWarrantFee.represent(object.warrant_fee)
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
