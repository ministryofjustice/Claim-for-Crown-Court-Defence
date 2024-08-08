require_relative 'sections/common_date_section'
require_relative 'sections/common_autocomplete_section'
require_relative 'sections/govuk_date_section'
require_relative 'sections/supplier_numbers_section'
require_relative 'sections/london_rates_section'
require_relative 'sections/retrial_section'
require_relative 'sections/cracked_trial_section'
require_relative 'sections/fee_dates_section'
require_relative 'sections/fee_section'
require_relative 'sections/fee_case_numbers_section'
require_relative 'sections/fixed_fee_case_numbers_section'
require_relative 'sections/basic_fee_section'
require_relative 'sections/fixed_fee_section'
require_relative 'sections/typed_fee_section'
require_relative 'sections/expense_section'
require_relative 'sections/offence_result_section'
require_relative 'sections/advocate_category_section'
require_relative 'sections/evidence_checklist_section'
require_relative 'sections/yes_no_section'

class ClaimFormPage < BasePage
  include SelectHelper

  set_url "/advocates/claims/new"

  element :providers_ref, "input[name='claim[providers_ref]']"
  section :auto_case_type, CommonAutocomplete, "#cc-case-type"
  section :auto_case_stage, CommonAutocomplete, "#cc-case-stage"
  section :auto_court, CommonAutocomplete, "#cc-court"
  section :auto_offence, CommonAutocomplete, "#cc-offence"
  section :main_hearing_date, GOVUKDateSection, '#main_hearing_date'

  element :case_number, "input[name='claim[case_number]']"
  element :case_type_dropdown, "#case_type"

  section :trial_details, "#trial-dates" do
    section :first_day_of_trial, GOVUKDateSection, '#first_day_of_trial'
    section :trial_concluded_on, GOVUKDateSection, '#trial_concluded_at'
    element :actual_trial_length, "input[name='claim[actual_trial_length]']"
    element :estimated_trial_length, "input[name='claim[estimated_trial_length]']"
  end

  section :retrial_details, RetrialSection, "#retrial-dates"
  section :cracked_trial_details, CrackedTrialSection, "#cracked-trial-dates"

  sections :defendants, ".defendant-details" do
    element :first_name, "div.cc-first-name input"
    element :last_name, "div.cc-last-name input"

    section :dob, GOVUKDateSection, 'div.cc-dob'

    sections :representation_orders, ".cc-ro-details" do
      section :date, GOVUKDateSection, 'div.cc-ro-date'
      element :maat_reference, "div.cc-maat input"
    end

    element :add_another_representation_order, "div.links > a"
  end

  element :add_another_defendant, ".defendants-actions a.add_fields"

  element :offence_search, "input[name='claim[offence_search]']"
  sections :offence_results, OffenceResultSection, '#offence-list div.fx-result-item'

  section :advocate_category_radios, AdvocateCategoryRadioSection, '.cc-advocate-categories'

  element :continue_button, '#save_continue'

  section :basic_fees, BasicFeeSection, "div#basic-fees"
  section :fixed_fees, FixedFeeSection, "div#fixed-fees"

  sections :miscellaneous_fees, TypedFeeSection, "div#misc-fees .misc-fee-group"
  element :add_another_miscellaneous_fee, "div#misc-fees > a.add_fields"

  sections :expenses, ExpenseSection, "div#expenses div.expense-group"
  element :add_another_expense, "div#expense > a.add_fields"
  element :additional_information_expenses, ".fx-additional-info"

  section :evidence_checklist, EvidenceChecklistSection, ".cc-evidence-checklist fieldset"

  element :additional_information, "textarea#claim-additional-information-field"
  element :continue, "div.button-holder > input:nth-of-type(1)"
  element :submit_to_laa, "div.button-holder > button:nth-of-type(1)" # this maps to Save and continue too
  element :save_to_drafts, "div.button-holder > button:nth-of-type(2)"

  sections :errors, "div.error-summary > ul > li" do
    element :message, "a"
  end

  section :lgfs_supplier_number_radios, SupplierNumberRadioSection, '.lgfs-supplier-numbers'
  section :auto_lgfs_supplier_number, CommonAutocomplete, ".lgfs-supplier-numbers"
  section :london_rates, LondonRatesRadioSection, ".london-rates"

  section :prosecution_evidence, YesNoSection, '.prosecution-evidence'

  def claim_id
    find('#claim-form')['data-claim-id']
  end

  def select_advocate(name)
    select name, from: "claim_external_user_id"
  end

  def select_offence_class(name)
    select name, from: "claim-offence-class-field", autocomplete: false
  end

  def add_fixed_fee_if_required
    if fixed_fees.last.populated?
      add_another_fixed_fee.click
    end
  end

  def add_misc_fee_if_required
    if miscellaneous_fees.last.populated?
      add_another_miscellaneous_fee.click
    end
  end

  def add_govuk_misc_fee_if_required
    if miscellaneous_fees.last.govuk_element_populated?
      add_another_miscellaneous_fee.click
    end
  end

  def attach_evidence(count: 1, document: '*')
    count ||= 1
    available_docs = Dir.glob "#{Rails.root}/spec/fixtures/files/#{document.gsub('.pdf','')}.pdf"
    available_docs[0...count].each do |path|
      # element needs to be visible in order to attach_file
      page.execute_script("$('.dropzone-enhanced [type=file]').css('position','unset')");
      attach_file("claim-documents-field", path)
    end
  end

  def check_evidence_checklist(count = 1)
    evidence_checklist.items_with_labels[0...count].each { |item| item.label.click }
  end

  def fee_block_for(section_or_sections, description)
    section = send(section_or_sections.to_sym)

    if section.respond_to?(:fee_block_for)
      section.fee_block_for(description)
    elsif section.map { |section| section.is_a?(TypedFeeSection) }.all?
      section.find { |section| section.select_input.value.eql?(description) }
    else
      raise ArgumentError, 'section(s) specified cannot identify specific fee sub-sections'
    end
  end

  def govuk_fee_block_for(section_or_sections, description)
    section = send(section_or_sections.to_sym)

    if section.respond_to?(:fee_block_for)
      section.fee_block_for(description)
    elsif section.map { |section| section.is_a?(TypedFeeSection) }.all?
      section.find { |section| section.govuk_fee_type_autocomplete_input.value.eql?(description) }
    else
      raise ArgumentError, 'section(s) specified cannot identify specific fee sub-sections'
    end
  end
end
