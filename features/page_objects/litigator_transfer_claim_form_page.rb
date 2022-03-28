require_relative 'sections/lgfs_transfer_detail_section'
require_relative 'sections/lgfs_transfer_fee_section'
require_relative 'litigator_claim_form_page'
require_relative 'sections/common_autocomplete_section'

class LitigatorTransferClaimFormPage < LitigatorClaimFormPage
  set_url "/litigators/transfer_claims/new"

  section :transfer_detail, LGFSTransferDetailSection, "#transfer-detail"
  section :transfer_fee, LGFSTransferFeeSection, "#transfer-fee"
  section :transfer_stage, CommonAutocomplete, "#cc-transfer-stage"
  section :case_conclusion, CommonAutocomplete, "#cc-case-conclusion"
end
