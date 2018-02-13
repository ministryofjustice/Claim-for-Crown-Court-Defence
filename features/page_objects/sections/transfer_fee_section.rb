class TransferFeeSection < SitePrism::Section
  include SelectHelper

  element :transfer_fee_total, "#claim_transfer_fee_attributes_amount"
  element :litigator_type_original, "#claim_litigator_type_original"
  element :litigator_type_new, "label[for='claim_litigator_type_new']"
  element :elected_case_yes, "label[for='claim_elected_case_true']"
  element :elected_case_no, "label[for='claim_elected_case_false']"

  section :transfer_date, CommonDateSection, '#transfer_date'

  def select_transfer_stage(name)
    select name, from: "claim_transfer_stage_id"
  end

  def select_case_conclusion(name)
    select name, from: "claim_case_conclusion_id"
  end
end
