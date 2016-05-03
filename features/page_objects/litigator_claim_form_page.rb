class DisbursementSection < SitePrism::Section
  include Select2Helper

  element :select2_container, "tr:nth-of-type(1) > td:nth-of-type(1) .autocomplete", visible: false
  element :net_amount, "tr:nth-of-type(1) input[data-calculator=net]"
  element :vat_amount, "tr:nth-of-type(1) input[data-calculator=vat]"

  def select_fee_type(name)
    id = select2_container[:id]
    select2 name, from: id
  end

  def populated?
    net_amount.value.size > 0
  end
end


class LitigatorClaimFormPage < ClaimFormPage

  set_url "/litigators/claims/new"

  section :case_concluded_date, CommonDateSection, 'div.case-concluded-date'

  sections :miscellaneous_fees, TypedFeeSection, "div#misc-fees tbody.misc-fee-group"
  element :add_another_miscellaneous_fee, "div#misc-fees > a.add_fields"

  sections :disbursements, DisbursementSection, "div#disbursements tbody.disbursement-group"
  element :add_another_disbursement, "div#disbursements > a.add_fields"

  element :fixed_fee_total, "#claim_fixed_fee_attributes_amount"

  def select_supplier_number(number)
    select2 number, from: "claim_supplier_number"
  end

  def select_offence_class(name)
    select2 name, from: "claim_offence_id"
  end

  def add_disbursement_if_required
    if disbursements.last.populated?
      add_another_disbursement.trigger "click"
    end
  end
end
