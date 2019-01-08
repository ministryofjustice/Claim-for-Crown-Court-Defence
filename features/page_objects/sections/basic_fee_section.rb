require_relative 'fee_section'
require_relative 'fee_dates_section'
require_relative 'fee_dates_section_condensed'
require_relative 'fee_case_numbers_section'

class BasicFeeSection < SitePrism::Section
  section :basic_fee, FeeSection, ".basic-fee.fee-details"

  element :number_of_case_uplift_input, ".fx-hook-noc"
  element :daily_attendance_fee_3_to_40_input, ".fx-hook-daf"

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

  sections :checklist, '.multiple-choice' do
    element :label, 'label'
    element :checkbox, 'input[type="checkbox"]', visible: false
  end

  def checklist_labels
    checklist.map { |item| item.label.text if item.has_label? }
  end

  def checklist_item_for(label)
    checklist.find do |item|
      item.label.text.match?(Regexp.new(Regexp.escape(label), true))
    end
  end

  def toggle(label)
    checklist.each do |item|
      item.label.click if item.label.text.match?(Regexp.new(label, true))
    end
  end

  def check(label)
    page.check checklist_item_for(label).checkbox['id'], visible: false
  end

  def uncheck(label)
    page.uncheck checklist_item_for(label).checkbox['id'], visible: false
  end
end
