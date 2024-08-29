require_relative 'claim_form_page'
require_relative 'sections/disbursement_section'
require_relative 'sections/typed_fee_amount_section'
require_relative 'sections/lgfs_graduated_fee_section'
require_relative 'sections/lgfs_fixed_fee_section'
require_relative 'sections/lgfs_misc_fee_section'

class LitigatorClaimFormPage < ClaimFormPage

  set_url "/litigators/claims/new"

  section :case_concluded_date, GOVUKDateSection, '#case_concluded_at'

  sections :miscellaneous_fees, LGFSMiscFeeSection, "div#misc-fees .misc-fee-group"
  element :add_another_miscellaneous_fee, "div#misc-fees a.add_fields"

  sections :disbursements, DisbursementSection, "div#disbursements .disbursement-group"
  element :add_another_disbursement, "div#disbursements a.add_fields"

  section :graduated_fee, LGFSGraduatedFeeSection, ".graduated-fee-group"
  section :fixed_fee, LGFSFixedFeeSection, ".fixed-fee-group"

  element :ppe_total, "input.quantity"
  element :actual_trial_length, ".js-fee-calculator-days"
  section :graduated_fee_date, GOVUKDateSection, "div.graduated-fee-group"
  element :sidebar_misc_amount, '.total-miscFees'

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

  def add_govuk_misc_fee_if_required
    if miscellaneous_fees.last.govuk_fee_type_autocomplete_input.value.present?
      add_another_miscellaneous_fee.click
    end
  end

end
