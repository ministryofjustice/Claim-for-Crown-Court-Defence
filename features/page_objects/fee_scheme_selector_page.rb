class FeeSchemeSelectorPage < BasePage
  set_url "/external_users/claims/types"

  element :advocate_final_fee, "label[for='claim-type-agfs-field']"
  element :advocate_hardship_fee, "label[for='claim-type-agfs-hardship-field']"
  element :advocate_interim_fee, "label[for='claim-type-agfs-interim-field']"
  element :advocate_supplementary_fee, "label[for='claim-type-agfs-supplementary-field']"
  element :litigator_final_fee, "label[for='claim-type-lgfs-final-field']"
  element :litigator_interim_fee, "label[for='claim-type-lgfs-interim-field']"
  element :litigator_transfer_fee, "label[for='claim-type-lgfs-transfer-field']"
  element :litigator_hardship_fee, "label[for='claim-type-lgfs-hardship-field']"

  element :continue, "input[value='Continue']"
end
