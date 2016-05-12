require_relative 'litigator_claim_form_page'

class TransferClaimFormPage < LitigatorClaimFormPage

  set_url "/litigators/transfer_claims/new"

  section :transfer_fee, TransferFeeSection, "div#transfer-fee"

end
