class FeeSchemeSelectorPage < BasePage
  set_url "/external_users/claims/types"

  element :advocate_final_fee,     "label[for='claim_type_agfs']"
  element :advocate_interim_fee,   "label[for='claim_type_agfs_interim']"
  element :advocate_supplementary_fee,   "label[for='claim_type_agfs_supplementary']"
  element :litigator_final_fee,    "label[for='claim_type_lgfs_final']"
  element :litigator_interim_fee,  "label[for='claim_type_lgfs_interim']"
  element :litigator_transfer_fee, "label[for='claim_type_lgfs_transfer']"
  element :litigator_hardship_fee, "label[for='claim_type_lgfs_hardship']"

  element :continue, "div.form-group > input:nth-of-type(1)"
end
