module API
  module Entities
    class ProvisionalAssessment < BaseEntity
      expose :scheme
      expose :provider_name
      expose :provider_type
      expose :supplier_number
      expose :case_type
      expose :offence_name
      expose :offence_type
      expose :ppe
      expose :number_of_trial_days
      expose :date_submitted
      expose :disbursements_claimed
      expose :fees_claimed
      expose :expenses_claimed
      expose :total_claimed
      expose :disbursements_authorised
      expose :fees_authorised
      expose :expenses_authorised
      expose :total_authorised
      expose :total_percent_authorised
      expose :fees_percent_authorised
      expose :expenses_percent_authorised
      expose :disbursements_percent_authorised
    end
  end
end
