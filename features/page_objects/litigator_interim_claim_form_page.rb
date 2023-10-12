require_relative 'litigator_claim_form_page'
require_relative 'sections/lgfs_interim_fee_section'

class LitigatorInterimClaimFormPage < LitigatorClaimFormPage
  set_url "/litigators/interim_claims/new"

  section :interim_fee, LGFSInterimFeeSection, "#interim-fee .interim-fee-group"
end
