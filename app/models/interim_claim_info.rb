class InterimClaimInfo < ApplicationRecord
  MINIMUM_PERIOD_SINCE_ISSUED = 3.months

  self.table_name = 'interim_claim_info'

  belongs_to :claim, class_name: 'Claim::BaseClaim'

  validates_with InterimClaimInfoValidator

  def perform_validation?
    claim&.perform_validation?
  end
end
