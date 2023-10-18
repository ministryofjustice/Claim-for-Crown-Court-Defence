require_relative 'claim_form_page'

class AdvocateInterimClaimFormPage < ClaimFormPage
  set_url "/advocates/interim_claims/new"

  section :warrant_issued_date, GOVUKDateSection, ".warrant-fee-issued-date-group"
  element :warrant_net_amount, '.warrant_fee_attributes_amount'
end
