class LGFSTransferDetailSection < SitePrism::Section
  include SelectHelper

  element :litigator_type_original, "#claim-litigator-type-original-field"
  element :litigator_type_new, "label[for='claim-litigator-type-new-field']"
  element :elected_case_yes, "label[for='claim-elected-case-true-field']"
  element :elected_case_no, "label[for='claim-elected-case-false-field']"

  section :transfer_date, GovukDateSection, '#cc-transfer_date'
end
