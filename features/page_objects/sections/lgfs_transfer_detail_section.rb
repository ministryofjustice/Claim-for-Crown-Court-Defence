class LgfsTransferDetailSection < SitePrism::Section
  include SelectHelper

  element :litigator_type_original, "#claim_litigator_type_original"
  element :litigator_type_new, "label[for='claim_litigator_type_new']"
  element :elected_case_yes, "label[for='claim_elected_case_true']"
  element :elected_case_no, "label[for='claim_elected_case_false']"

  section :transfer_date, CommonDateSection, '#transfer_date'
end
