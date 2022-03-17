require_relative 'checkbox_fee_section'

class FixedFeeSection < CheckboxFeeSection
  section :adjourned_appeals_committals_and_breaches, FeeSection, "div[data-target='adjourned-appeals-committals-and-breaches'] .fixed-fee-group"
  section :appeals_to_the_crown_court_against_sentence, FeeSection, "div[data-target='appeals-to-the-crown-court-against-sentence'] .fixed-fee-group"
  section :appeals_to_the_crown_court_against_conviction, FeeSection, "div[data-target='appeals-to-the-crown-court-against-conviction'] .fixed-fee-group"
  section :number_of_cases_uplift, FixedFeeCaseNumbersSection, "div[data-target='number-of-cases-uplift'] .fixed-fee-group"
  section :number_of_defendants_uplift, FeeSection, "div[data-target='number-of-defendants-uplift'] .fixed-fee-group"
  section :standard_appearance_fee, FeeSection, "div[data-target='tandard-appearance-fee'] .fixed-fee-group"
  section :elected_case_not_proceeded, FeeSection, "div[data-target='elected-case-not-proceeded'] .fixed-fee-group"
end
