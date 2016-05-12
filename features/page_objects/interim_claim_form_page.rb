require_relative 'litigator_claim_form_page'
require_relative 'sections/interim_fee_section'

class InterimClaimFormPage < LitigatorClaimFormPage

  set_url "/litigators/interim_claims/new"

  section :interim_fee, InterimFeeSection, "div#interim-fee div.interim-fee-group"

end
