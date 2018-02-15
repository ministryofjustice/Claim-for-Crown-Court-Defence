require_relative 'common_date_section'

class RetrialSection < SitePrism::Section
  section :retrial_started_at, CommonDateSection, '#retrial_started_at'
  section :retrial_concluded_at, CommonDateSection, '#retrial_concluded_at'
  element :retrial_actual_length, "#claim_retrial_actual_length"
  element :retrial_estimated_length, "#claim_retrial_estimated_length"
  element :retrial_reduction_yes, "label[for='claim_retrial_reduction_true']"
  element :retrial_reduction_no, "label[for='claim_retrial_reduction_false']"
end
