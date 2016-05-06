require_relative 'litigator_claim_form_page'
require_relative 'sections/interim_fee_section'

class InterimClaimFormPage < LitigatorClaimFormPage

  set_url "/litigators/interim_claims/new"

  section :interim_fee, InterimFeeSection, "div#interim-fee div.interim-fee-group"

  sections :disbursements, DisbursementSection, "div#disbursements .disbursement-group"
  element :add_another_disbursement, "div#disbursements > a.add_fields"

  def add_disbursement_if_required
    if disbursements.last.populated?
      add_another_disbursement.trigger "click"
    end
  end
end
