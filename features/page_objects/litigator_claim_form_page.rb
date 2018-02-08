require_relative 'claim_form_page'
require_relative 'sections/supplier_numbers_section'
require_relative 'sections/disbursement_section'
require_relative 'sections/typed_fee_amount_section'

class LitigatorClaimFormPage < ClaimFormPage

  set_url "/litigators/claims/new"

  section :case_concluded_date, CommonDateSection, 'div.case-concluded-date'

  sections :miscellaneous_fees, TypedFeeAmountSection, "div#misc-fees .misc-fee-group"
  element :add_another_miscellaneous_fee, "div#misc-fees > a.add_fields"

  sections :disbursements, DisbursementSection, "div#disbursements .disbursement-group"
  element :add_another_disbursement, "div#disbursements > a.add_fields"

  element :fixed_fee_total, "#claim_fixed_fee_attributes_amount"
  section :fixed_fee_date, CommonDateSection, "div.fixed-fee-group"

  section :lgfs_supplier_numbers, SupplierNumbersSection, '.lgfs-supplier-numbers'

  def select_supplier_number(number)
    select number, from: "claim_supplier_number", autocomplete: false
  end

  def select_offence_class(name)
    select name, from: "claim_offence_id"
  end

  def add_disbursement_if_required
    if disbursements.last.populated?
      add_another_disbursement.trigger "click"
    end
  end
end
