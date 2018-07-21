require_relative 'fee_section'
require_relative 'fee_dates_section'
require_relative 'fee_dates_section_condensed'
require_relative 'fee_case_numbers_section'

class BasicFeeSection < SitePrism::Section
    section :basic_fee, FeeSection, ".basic-fee.fee-details"
    section :basic_fee_dates, FeeDatesSection, ".basic-fee.fee-details .fee-dates-row"

    element :number_of_case_uplift_input, ".fx-hook-noc"
    element :daily_attendance_fee_input, ".fx-hook-daf"

    section :daily_attendance_fee_2, FeeSection, ".basic-fee-group.daily-attendance-fee-2"
    section :daily_attendance_fee_3_to_40, FeeSection, ".basic-fee-group.daily-attendance-fee-3-to-40"
    section :daily_attendance_fee_3_to_40_dates, FeeDatesSectionCondensed, ".basic-fee-group.daily-attendance-fee-3-to-40 .dates-wrapper"
    section :daily_attendance_fee_41_to_50, FeeSection, ".basic-fee-group.daily-attendance-fee-41-to-50"
    section :daily_attendance_fee_51_plus, FeeSection, ".basic-fee-group.daily-attendance-fee-51"
    section :standard_appearance_fee, FeeSection, ".basic-fee-group.standard-appearance-fee"
    section :plea_and_trial_preparation_hearing, FeeSection, ".basic-fee-group.plea-and-trial-preparation-hearing"
    section :conferences_and_views, FeeSection, ".basic-fee-group.conferences-and-views"
    section :number_of_defendants_uplift, FeeSection, ".basic-fee-group.number-of-defendants-uplift"
    section :number_of_cases_uplift, FeeCaseNumbersSection, ".basic-fee-group.number-of-cases-uplift"

    sections :basic_fees_checklist, '#basic-fees .multiple-choice' do
      element :label, 'label'
      element :input, 'input'
    end

    def checklist_labels
      basic_fees_checklist.map { |item| item.label.text if item.has_label? }
    end
end
