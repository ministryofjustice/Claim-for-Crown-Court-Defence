module API
  module Entities
    module CCR
      class AdvocateInterimClaim < BaseEntity
        # TODO: find common functionality with advocate "final" claim and promote to CCR::BaseClaim class
        #
        expose :uuid
        expose :supplier_number
        expose :case_number
        expose  :first_day_of_trial, # will be nil
                :trial_fixed_notice_at, # will be nil
                :trial_fixed_at, # will be nil
                :trial_cracked_at, # will be nil
                :retrial_started_at, # will be nil
                :last_submitted_at,
                format_with: :utc
        expose :trial_cracked_at_third

        expose :adapted_advocate_category, as: :advocate_category
        # FIXME: dummy a guilty plea for injection purposes
        # CCR requires a bill scenario in order to calculate fees
        expose :case_type, using: API::Entities::CCR::CaseType
        expose :court, using: API::Entities::CCR::Court
        expose :offence, using: API::Entities::CCR::Offence
        expose :defendants_with_main_first, using: API::Entities::CCR::Defendant, as: :defendants

        expose :retrial_reduction

        with_options(format_with: :string) do
          expose :actual_trial_length_or_one, as: :actual_trial_Length # will be nil
          expose :estimated_trial_length_or_one, as: :estimated_trial_length # will be nil
          expose :retrial_actual_length_or_one, as: :retrial_actual_length # will be nil
          expose :retrial_estimated_length_or_one, as: :retrial_estimated_length # will be nil
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
