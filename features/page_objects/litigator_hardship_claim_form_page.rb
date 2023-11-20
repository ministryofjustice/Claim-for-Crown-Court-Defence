require_relative 'litigator_claim_form_page'
require_relative 'sections/lgfs_hardship_fee_section'

class LitigatorHardshipClaimFormPage < LitigatorClaimFormPage
  set_url "/litigators/hardship_claims/new"

  section :hardship_fee, LGFSHardshipFeeSection, "#hardship-fee .hardship-fee-group"
end
