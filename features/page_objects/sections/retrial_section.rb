require_relative 'common_date_section'
require_relative 'govuk_date_section'

class RetrialSection < SitePrism::Section
  section :retrial_started_at, GovukDateSection, '#retrial_started_at'
  section :retrial_concluded_at, GovukDateSection, '#retrial_concluded_at'

  element :retrial_actual_length, "input[name='claim[retrial_actual_length]']"
  element :retrial_estimated_length, "input[name='claim[retrial_estimated_length]']"
  element :retrial_reduction_yes, "label[for='claim-retrial-reduction-true-field']"
  element :retrial_reduction_no, "label[for='claim-retrial-reduction-false-field']"
end
