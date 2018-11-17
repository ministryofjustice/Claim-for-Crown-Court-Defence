require_relative 'sections/transfer_fee_section'
require_relative 'litigator_claim_form_page'

class LitigatorTransferClaimFormPage < LitigatorClaimFormPage

  set_url "/litigators/transfer_claims/new"

  section :transfer_fee, TransferFeeSection, "div#transfer-fee"

end
