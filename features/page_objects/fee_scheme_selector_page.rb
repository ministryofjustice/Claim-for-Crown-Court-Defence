class FeeSchemeSelectorPage < BasePage
  set_url '/external_users/claim_types/new'

  element :advocate_final_fee, "label[for='claim-type-id-agfs-field']"
  element :advocate_hardship_fee, "label[for='claim-type-id-agfs-hardship-field']"
  element :advocate_interim_fee, "label[for='claim-type-id-agfs-interim-field']"
  element :advocate_supplementary_fee, "label[for='claim-type-id-agfs-supplementary-field']"
  element :litigator_final_fee, "label[for='claim-type-id-lgfs-final-field']"
  element :litigator_interim_fee, "label[for='claim-type-id-lgfs-interim-field']"
  element :litigator_transfer_fee, "label[for='claim-type-id-lgfs-transfer-field']"
  element :litigator_hardship_fee, "label[for='claim-type-id-lgfs-hardship-field']"

  element :continue, "input[value='Continue']"
end
