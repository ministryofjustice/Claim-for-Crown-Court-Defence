require_relative 'sections/common_date_section'
require_relative 'sections/supplier_numbers_section'
require_relative 'sections/retrial_section'
require_relative 'sections/fee_case_numbers_section'
require_relative 'sections/fee_dates_section_condensed'
require_relative 'sections/fee_dates_section'
require_relative 'sections/fee_section'
require_relative 'sections/typed_fee_section'
require_relative 'sections/expense_section'

class ClaimFormPage < SitePrism::Page
  include DropzoneHelper
  include SelectHelper

  set_url "/advocates/claims/new"

  element :claim_advocate_category_junior_alone, "#claim_advocate_category_junior_alone"
  element :court, "#s2id_autogen1"
  element :case_type, "#s2id_autogen2"
  element :case_number, "#claim_case_number"

  section :trial_details, "#trial-details" do
    section :first_day_of_trial, CommonDateSection, '#first_day_of_trial'
    section :trial_concluded_on, CommonDateSection, '#trial_concluded_at'
    element :actual_trial_length, "#claim_actual_trial_length"
    element :estimated_trial_length, '#claim_estimated_trial_length'
  end

  section :retrial_details, RetrialSection, "#retrial-details"

  sections :defendants, ".defendant-details" do
    element :first_name, "div.first-name input"
    element :last_name, "div.last-name input"

    section :dob, CommonDateSection, 'div.dob'

    sections :representation_orders, ".ro-details" do
      section :date, CommonDateSection, 'div.ro-date'
      element :maat_reference, "div.maat input"
    end

    element :add_another_representation_order, "div.links > a"
  end

  element :add_another_defendant, ".defendants-actions a.add_fields"

  element :continue_button, 'div.button-holder > input.button.left'

  section :initial_fees, "div#basic-fees" do
    # In CSS 'foo + bar' means instances of bar which immediately follow foo and
    # have the same parent.
    section :basic_fee, FeeSection, ".basic-fee.fee-details"
    section :basic_fee_dates, FeeDatesSection, ".basic-fee.fee-details .fee-dates-row"

    section :daily_attendance_fee_3_to_40, FeeSection, ".basic-fee-group.daily-attendance-fee-3-to-40"
    section :daily_attendance_fee_3_to_40_dates, FeeDatesSectionCondensed, ".basic-fee-group.daily-attendance-fee-3-to-40 .dates-wrapper"

    section :daily_attendance_fee_41_to_50, FeeSection, ".basic-fee-group.daily-attendance-fee-41-to-50"
    section :daily_attendance_fee_51_plus, FeeSection, ".basic-fee-group.daily-attendance-fee-51"
    section :standard_appearance_fee, FeeSection, ".basic-fee-group.standard-appearance-fee"
    section :plea_and_case_management_hearing, FeeSection, ".basic-fee-group.plea-and-case-management-hearing"
    section :conferences_and_views, FeeSection, ".basic-fee-group.conferences-and-views"
    section :number_of_defendants_uplift, FeeSection, ".basic-fee-group.number-of-defendants-uplift"
    section :number_of_cases_uplift, FeeCaseNumbersSection, ".basic-fee-group.number-of-cases-uplift"
  end

  sections :miscellaneous_fees, TypedFeeSection, "div#misc-fees .misc-fee-group"
  element :add_another_miscellaneous_fee, "div#misc-fees > .form-group > a.add_fields"

  sections :fixed_fees, TypedFeeSection, "div#fixed-fees .fixed-fee-group"
  element :add_another_fixed_fee, "div#fixed-fees > .form-group > a.add_fields"

  sections :expenses, ExpenseSection, "div#expenses div.expense-group"
  element :add_another_expense, "div#expense > a.add_fields"

  sections :evidence_checklist, "div.evidence-checklist > div" do
    element :check, "input"
  end

  element :additional_information, "textarea#claim_additional_information"
  element :continue, "div.button-holder > input:nth-of-type(1)"
  element :submit_to_laa, "div.button-holder > input:nth-of-type(1)"
  element :save_to_drafts, "div.button-holder > input:nth-of-type(2)"

  sections :errors, "div.error-summary > ul > li" do
    element :message, "a"
  end

  section :lgfs_supplier_number_radios, SupplierNumberRadioSection, '.lgfs-supplier-numbers'
  element :lgfs_supplier_number_select, 'select#claim_supplier_number'

  def select_advocate(name)
    select name, from: "claim_external_user_id"
  end

  def select_court(name)
    select name, from: "claim_court_id"
  end

  def select_case_type(name)
    select name, from: "claim_case_type_id"
  end

  def select_offence_category(name)
    select name, from: "claim_offence_category_description"
  end

  def select_offence_class(name)
    select name, from: "offence_class_description", autocomplete: false
  end

  def add_fixed_fee_if_required
    if fixed_fees.last.populated?
      add_another_fixed_fee.trigger "click"
    end
  end

  def add_misc_fee_if_required
    if miscellaneous_fees.last.populated?
      add_another_miscellaneous_fee.trigger "click"
    end
  end

  def attach_evidence(count = 1)
    available_docs = Dir.glob "#{Rails.root}/spec/fixtures/files/*.pdf"

    available_docs[0...count].each do |path|
      # puts "      Attaching #{path}"
      drag_and_drop_file("dropzone", path)
    end
  end

  def check_evidence_checklist(count = 1)
    evidence_checklist[0...count].each { |item| item.check.trigger "click" }
  end
end
