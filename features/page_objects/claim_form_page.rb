class FeeSection < SitePrism::Section
  element :quantity, "input.quantity"
  element :rate, "input.rate"
  element :add_dates, "td:nth-of-type(5) > a"
end

class FeeDatesSection < SitePrism::Section
  section :from, "td:nth-of-type(1) > span:nth-of-type(1)" do
    include DateHelper
    element :day, "input:nth-of-type(1)"
    element :month, "input:nth-of-type(2)"
    element :year, "input:nth-of-type(3)"
  end

  section :to, "td:nth-of-type(1) > span:nth-of-type(2)" do
    include DateHelper
    element :day, "input:nth-of-type(1)"
    element :month, "input:nth-of-type(2)"
    element :year, "input:nth-of-type(3)"
  end
end

class TypedFeeSection < SitePrism::Section
  include Select2Helper

  element :select2_container, "tr:nth-of-type(1) > td:nth-of-type(1) div.select2-container"
  element :quantity, "tr:nth-of-type(1) input.quantity"
  element :rate, "tr:nth-of-type(1) input.rate"
  element :add_dates, "tr:nth-of-type(1) > td:nth-of-type(5) > a"
  section :dates, FeeDatesSection, "tr.fee-dates"

  def select_fee_type(name)
    id = select2_container[:id]
    select2 name, from: id[5, id.size-1]
  end

  def populated?
    rate.value.size > 0
  end
end

class ExpenseSection < SitePrism::Section
  include Select2Helper

  element :select2_container, "tr:nth-of-type(1) td:nth-of-type(1) div.select2-container"
  element :destination, "tr:nth-of-type(1) td:nth-of-type(2) input"
  element :quantity, "tr:nth-of-type(1) input.quantity"
  element :rate, "tr:nth-of-type(1) input.rate"
  element :add_dates, "tr:nth-of-type(1) > td.add-expense-date-attended a"
  section :dates, FeeDatesSection, "tr.fee-dates"

  def select_type_of_expense(name)
    id = select2_container[:id]
    select2 name, from: id[5, id.size-1]
  end
end

class ClaimFormPage < SitePrism::Page
  include DropzoneHelper
  include Select2Helper

  set_url "/advocates/claims/new"

  element :claim_advocate_category_junior_alone, "#claim_advocate_category_junior_alone"
  element :court, "#s2id_autogen1"
  element :case_type, "#s2id_autogen2"
  element :case_number, "#claim_case_number"

  section :trial_details, "#trial-details" do
    section :first_day_of_trial, "span:nth-of-type(1)" do
      include DateHelper
      element :day, "input#claim_first_day_of_trial_dd"
      element :month, "input#claim_first_day_of_trial_mm"
      element :year, "input#claim_first_day_of_trial_yyyy"
    end

    element :actual_trial_length, "#claim_actual_trial_length"

    section :trial_concluded_on, "span:nth-of-type(4)" do
      include DateHelper
      element :day, "input#claim_trial_concluded_at_dd"
      element :month, "input#claim_trial_concluded_at_mm"
      element :year, "input#claim_trial_concluded_at_yyyy"
    end
  end

  element :offence_category, "#s2id_autogen3"

  sections :defendants, "div.defendants > div.js-test-defendant" do
    element :first_name, "span.first-name > input"
    element :last_name, "span.last-name > input"

    section :dob, "span.dob" do
      include DateHelper
      element :day, "input:nth-of-type(1)"
      element :month, "input:nth-of-type(2)"
      element :year, "input:nth-of-type(3)"
    end

    sections :representation_orders, "div.js-test-rep-order" do
      include DateHelper
      element :day, "span.ro-date > input:nth-of-type(1)"
      element :month, "span.ro-date > input:nth-of-type(2)"
      element :year, "span.ro-date > input:nth-of-type(3)"
      element :maat_reference, "span.maat > input"
    end

    element :add_another_representation_order, "div.links > a"
  end

  element :add_another_defendant, "div.defendants > div:nth-of-type(2) > a.add_fields"

  section :initial_fees, "div#basic-fees" do
    # In CSS 'foo + bar' means instances of bar which immediately follow foo and
    # have the same parent.
    section :basic_fee, FeeSection, "tr.basic-fee.fee-details"
    section :basic_fee_dates, FeeDatesSection, "tr.basic-fee.fee-details + tr.fee-dates"

    section :daily_attendance_fee_3_to_40, FeeSection, "tr.fee-details.daily-attendance-fee-3-to-40"
    section :daily_attendance_fee_3_to_40_dates, FeeDatesSection, "tr.fee-details.daily-attendance-fee-3-to-40 + tr.fee-dates"

    section :daily_attendance_fee_41_to_50, FeeSection, "tr.fee-details.daily-attendance-fee-41-to-50"
    section :daily_attendance_fee_51_plus, FeeSection, "tr.fee-details.daily-attendance-fee-51"
    section :standard_appearance_fee, FeeSection, "tr.fee-details.standard-appearance-fee"
    section :plea_and_case_management_hearing, FeeSection, "tr.fee-details.plea-and-case-management-hearing"
    section :conferences_and_views, FeeSection, "tr.fee-details.conferences-and-views"
    section :number_of_defendants_uplift, FeeSection, "tr.fee-details.number-of-defendants-uplift"
    section :number_of_cases_uplift, FeeSection, "tr.fee-details.number-of-cases-uplift"
  end

  sections :miscellaneous_fees, TypedFeeSection, "div#misc-fees tbody.misc-fee-group"
  element :add_another_miscellaneous_fee, "div#misc-fees > a.add_fields"

  sections :fixed_fees, TypedFeeSection, "div#fixed-fees tbody.fixed-fee-group"
  element :add_another_fixed_fee, "div#fixed-fees > a.add_fields"

  sections :expenses, ExpenseSection, "div#expenses div.expense-group"
  element :add_another_expense, "div#expense > a.add_fields"

  sections :evidence_checklist, "div.evidence-checklist > div" do
    element :check, "input"
  end

  element :additional_information, "div.grid-row > div.column-half > textarea"
  element :submit_to_laa, "div.button-holder > input:nth-of-type(1)"
  element :save_to_drafts, "div.button-holder > input:nth-of-type(2)"

  sections :errors, "div.error-summary > ul > li" do
    element :message, "a"
  end

  def select_advocate(name)
    select2 name, from: "claim_external_user_id"
  end

  def select_court(name)
    select2 name, from: "claim_court_id"
  end

  def select_case_type(name)
    select2 name, from: "claim_case_type_id"
  end

  def select_offence_category(name)
    select2 name, from: "offence_category_description"
  end

  def add_misc_fee_if_required
    if miscellaneous_fees.last.populated?
      add_another_miscellaneous_fee.trigger "click"
    end
  end

  def attach_evidence(count = 1)
    available_docs = Dir.glob "spec/fixtures/files/*.pdf"

    available_docs[0...count].each do |path|
      puts "      Attaching #{path}"
      drag_and_drop_file("dropzone", path)
    end
  end

  def check_evidence_checklist(count = 1)
    evidence_checklist[0...count].each { |item| item.check.trigger "click" }
  end
end
