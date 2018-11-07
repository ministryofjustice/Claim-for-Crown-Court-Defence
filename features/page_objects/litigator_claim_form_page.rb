require_relative 'claim_form_page'
require_relative 'sections/disbursement_section'
require_relative 'sections/typed_fee_amount_section'
require_relative 'sections/lgfs_fixed_fee_section'

class LitigatorClaimFormPage < ClaimFormPage

  set_url "/litigators/claims/new"

  section :case_concluded_date, CommonDateSection, 'div.case-concluded-date'

  sections :miscellaneous_fees, TypedFeeAmountSection, "div#misc-fees .misc-fee-group"
  element :add_another_miscellaneous_fee, "div#misc-fees a.add_fields"

  sections :disbursements, DisbursementSection, "div#disbursements .disbursement-group"
  element :add_another_disbursement, "div#disbursements > a.add_fields"

  section :fixed_fee, LgfsFixedFeeSection, ".fixed-fee-group"

  element :ppe_total, "#claim_graduated_fee_attributes_quantity"
  element :actual_trial_length, "#claim_actual_trial_length"
  element :graduated_fee_total, "#claim_graduated_fee_attributes_amount"
  section :graduated_fee_date, CommonDateSection, "div.graduated-fee-group"

  element :warrant_fee_total, "#claim_warrant_fee_attributes_amount"
  section :warrant_fee_issued_date, CommonDateSection, "div.warrant-fee-issued-date-group"
  section :warrant_fee_executed_date, CommonDateSection, "div.warrant-fee-executed-date-group"

  def select_supplier_number(number)
    select number, from: "claim_supplier_number", autocomplete: false
  end

  def select_offence_class(name)
    select name, from: "claim_offence_id"
  end

  def add_disbursement_if_required
    if disbursements.last.populated?
      add_another_disbursement.click
    end
  end
end
