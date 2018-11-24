class InterimClaimInfo < ApplicationRecord
  MINIMUM_PERIOD_SINCE_ISSUED = 3.months

  self.table_name = 'interim_claim_info'

  belongs_to :claim, class_name: 'Claim::BaseClaim', foreign_key: :claim_id

  validates_with InterimClaimInfoValidator

  acts_as_gov_uk_date :warrant_issued_date, :warrant_executed_date

  def perform_validation?
    claim&.perform_validation?
  end
end
