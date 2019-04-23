require_relative 'checkbox_fee_section'

class MiscellaneousFeeSection < CheckboxFeeSection
  section :confiscation_hearings_half_day_uplift, FixedFeeCaseNumbersSection, "#confiscation-hearings-half-day-uplift > .misc-fee-group"
  section :confiscation_hearings_half_day, FeeSection, "#confiscation-hearings-half-day > .misc-fee-group"
  section :confiscation_hearings_whole_day_uplift, FeeSection, "#confiscation-hearings-whole-day-uplift > .misc-fee-group"
  section :confiscation_hearings_whole_day, FeeSection, "#confiscation-hearings-whole-day > .misc-fee-group"
  section :deferred_sentence_hearings_uplift, FeeSection, "#deferred-sentence-hearings-uplift > .misc-fee-group"
  section :deferred_sentence_hearings, FeeSection, "#deferred-sentence-hearings > .misc-fee-group"
  section :plea_and_trial_preparation_hearing, FeeSection, "#plea-and-trial-preparation-hearing > .misc-fee-group"
  section :special_preparation_fee, FeeSection, "#special-preparation-fee > .misc-fee-group"
  section :standard_appearance_fee_uplift, FeeSection, "#standard-appearance-fee-uplift > .misc-fee-group"
  section :standard_appearance_fee, FeeSection, "#standard-appearance-fee > .misc-fee-group"
  section :wasted_preparation_fee, FeeSection, "#wasted-preparation-fee > .misc-fee-group"
end
