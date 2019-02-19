require_relative 'sections/lgfs_transfer_detail_section'
require_relative 'sections/lgfs_transfer_fee_section'
require_relative 'litigator_claim_form_page'
require_relative 'sections/common_autocomplete_section'

class LitigatorTransferClaimFormPage < LitigatorClaimFormPage
  set_url "/litigators/transfer_claims/new"

  section :transfer_detail, LgfsTransferDetailSection, "#transfer-detail"
  section :transfer_fee, LgfsTransferFeeSection, "#transfer-fee"
  section :auto_one, CommonAutocomplete, "#cc-transfer-stage"
  section :auto_two, CommonAutocomplete, "#cc-case-conclusion"
end
