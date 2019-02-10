require_relative 'claim_form_page'
require_relative 'sections/miscellaneous_fee_section'

class AdvocateSupplementaryClaimFormPage < ClaimFormPage
  set_url "/advocates/supplementary_claims/new"

  section :miscellaneous_fees, MiscellaneousFeeSection, "div#misc-fees"
end
