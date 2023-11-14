require_relative 'checkbox_fee_section'

class MiscellaneousFeeSection < CheckboxFeeSection
  section :additional_preparation_fee, FeeSection, "[data-target = 'additional-preparation-fee'] .misc-fee-group"
  section :confiscation_hearings_half_day_uplift, FixedFeeCaseNumbersSection, "[data-target = 'confiscation-hearings-half-day-uplift'] .misc-fee-group"
  section :confiscation_hearings_half_day, FeeSection, "[data-target = 'confiscation-hearings-half-day'] .misc-fee-group"
  section :confiscation_hearings_whole_day_uplift, FeeSection, "[data-target = 'confiscation-hearings-whole-day-uplift'] .misc-fee-group"
  section :confiscation_hearings_whole_day, FeeSection, "[data-target = 'confiscation-hearings-whole-day'] .misc-fee-group"
  section :deferred_sentence_hearings_uplift, FeeSection, "[data-target = 'deferred-sentence-hearings-uplift'] .misc-fee-group"
  section :deferred_sentence_hearings, FeeSection, "[data-target = 'deferred-sentence-hearings > .misc-fee-group"
  section :plea_and_trial_preparation_hearing, FeeSection, "[data-target = 'plea-and-trial-preparation-hearing'] .misc-fee-group"
  section :special_preparation_fee, FeeSection, "[data-target = 'special-preparation-fee'] .misc-fee-group"
  section :section_28_hearing, FeeSection, "[data-target = 'section-28-hearing'] .misc-fee-group"
  section :standard_appearance_fee_uplift, FeeSection, "[data-target = 'standard-appearance-fee-uplift'] .misc-fee-group"
  section :standard_appearance_fee, FeeSection, "[data-target = 'standard-appearance-fee'] .misc-fee-group"
  section :wasted_preparation_fee, FeeSection, "[data-target = 'wasted-preparation-fee'] .misc-fee-group"
end
