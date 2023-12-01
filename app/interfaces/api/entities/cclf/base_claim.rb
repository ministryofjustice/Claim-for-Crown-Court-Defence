module API
  module Entities
    module CCLF
      class BaseClaim < API::Entities::BaseEntity
        expose :uuid
        expose :supplier_number
        expose :case_number
        expose  :first_day_of_trial,
                :retrial_started_at,
                :case_concluded_at,
                :last_submitted_at,
                :main_hearing_date,
                format_with: :utc

        expose :actual_trial_length_or_one, as: :actual_trial_Length, format_with: :string

        # CCLF specific incarnations of claim sub model entities
        expose :case_type, using: API::Entities::CCLF::CaseType
        expose :offence, using: API::Entities::CCLF::Offence

        # reuse CCR entities where they are identical
        expose :court, using: API::Entities::CCR::Court
        expose :defendants_with_main_first, using: API::Entities::CCR::Defendant, as: :defendants

        expose :additional_information
        expose :apply_vat

        expose :bills

        private

        def actual_trial_length_or_one
          object.actual_trial_length.or_one
        end

        # case type adapter requires access to claim object
        def case_type
          object
        end

        def defendants_with_main_first
          object.defendants.order(created_at: :asc)
        end

        def bills
          raise 'Implement in sub-class'
        end
      end
    end
  end
end
