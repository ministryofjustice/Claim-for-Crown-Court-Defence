require_relative 'common_date_section'

class CrackedTrialSection < SitePrism::Section
  section :trial_fixed_notice_at, GovukDateSection, '#trial_fixed_notice_at'
  section :trial_fixed_at, GovukDateSection, '#trial_fixed_at'
  section :trial_cracked_at, GovukDateSection, '#trial_cracked_at'

  element :first_third, "label[for='claim_trial_cracked_at_third_first_third']"
  element :second_third, "label[for='claim_trial_cracked_at_third_second_third']"
  element :final_third, "label[for='claim_trial_cracked_at_third_final_third']"
end
