require_relative 'litigator_claim_form_page'

class TransferClaimFormPage < LitigatorClaimFormPage

  set_url "/litigators/transfer_claims/new"

  element :transfer_fee_total, "#claim_transfer_fee_attributes_amount"
  element :litigator_type_original, "#claim_transfer_detail_attributes_litigator_type_original"
  element :litigator_type_new, "#claim_transfer_detail_attributes_litigator_type_new"
  element :elected_case_yes, "#claim_transfer_detail_attributes_elected_case_true"
  element :elected_case_no, "#claim_transfer_detail_attributes_elected_case_false"

  section :transfer_date, CommonDateSection, '#transfer_date'

  sections :disbursements, DisbursementSection, "div#disbursements .disbursement-group"
  element :add_another_disbursement, "div#disbursements > a.add_fields"

  def select_transfer_stage(name)
    select2 name, from: "claim_transfer_detail_attributes_transfer_stage_id"
  end

  def select_case_conclusion(name)
    select2 name, from: "claim_transfer_detail_attributes_case_conclusion_id"
  end

  def add_disbursement_if_required
    if disbursements.last.populated?
      add_another_disbursement.trigger "click"
    end
  end
end
