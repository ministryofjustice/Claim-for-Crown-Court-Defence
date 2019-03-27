require_relative 'checkbox_fee_section'

class FixedFeeSection < CheckboxFeeSection
  section :adjourned_appeals_committals_and_breaches, FeeSection, "#adjourned-appeals-committals-and-breaches > .fixed-fee-group"
  section :appeals_to_the_crown_court_against_sentence, FeeSection, "#appeals-to-the-crown-court-against-sentence > .fixed-fee-group"
  section :appeals_to_the_crown_court_against_conviction, FeeSection, "#appeals-to-the-crown-court-against-conviction > .fixed-fee-group"
  section :number_of_cases_uplift, FixedFeeCaseNumbersSection, "#number-of-cases-uplift > .fixed-fee-group"
  section :number_of_defendants_uplift, FeeSection, "#number-of-defendants-uplift > .fixed-fee-group"
  section :standard_appearance_fee, FeeSection, "#standard-appearance-fee > .fixed-fee-group"
  section :elected_case_not_proceeded, FeeSection, "#elected-case-not-proceeded > .fixed-fee-group"
end
