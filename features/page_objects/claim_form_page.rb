require_relative 'sections/common_date_section'
require_relative 'sections/common_autocomplete_section'
require_relative 'sections/supplier_numbers_section'
require_relative 'sections/retrial_section'
require_relative 'sections/fee_dates_section_condensed'
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


class ClaimFormPage < SitePrism::Page
  include DropzoneHelper
  include SelectHelper

  set_url "/advocates/claims/new"

  element :providers_ref, "#claim_providers_ref"
  section :auto_case_type, CommonAutocomplete, "#cc-case-type"
  section :auto_court, CommonAutocomplete, "#cc-court"
  element :case_number, "#claim_case_number"

  section :trial_details, "#trial-dates" do
    section :first_day_of_trial, CommonDateSection, '#first_day_of_trial'
    section :trial_concluded_on, CommonDateSection, '#trial_concluded_at'
    element :actual_trial_length, "#claim_actual_trial_length"
    element :estimated_trial_length, '#claim_estimated_trial_length'
  end

  section :retrial_details, RetrialSection, "#retrial-dates"

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

  element :offence_search, "input[name='offence-search-input']"
  sections :offence_results, OffenceResultSection, '#offence-list div.fx-result-item'

  section :advocate_category_radios, AdvocateCategoryRadioSection, '.advocate-categories'

  element :continue_button, '#save_continue'

  section :basic_fees, BasicFeeSection, "div#basic-fees"
  section :fixed_fees, FixedFeeSection, "div#fixed-fees"

  sections :miscellaneous_fees, TypedFeeSection, "div#misc-fees .misc-fee-group"
  element :add_another_miscellaneous_fee, "div#misc-fees > .form-group > a.add_fields"

  sections :expenses, ExpenseSection, "div#expenses div.expense-group"
  element :add_another_expense, "div#expense > a.add_fields"
  element :additional_information_expenses, ".fx-additional-info"

  section :evidence_checklist, EvidenceChecklistSection, "fieldset.evidence-checklist"

  element :additional_information, "textarea#claim_additional_information"
  element :continue, "div.button-holder > input:nth-of-type(1)"
  element :submit_to_laa, "div.button-holder > input:nth-of-type(1)" # this maps to Save and continue too
  element :save_to_drafts, "div.button-holder > input:nth-of-type(2)"

  sections :errors, "div.error-summary > ul > li" do
    element :message, "a"
  end

  section :lgfs_supplier_number_radios, SupplierNumberRadioSection, '.lgfs-supplier-numbers'
  element :lgfs_supplier_number_select, 'select#claim_supplier_number'

  def claim_id
    find('#claim-form')['data-claim-id']
  end

  def select_advocate(name)
    select name, from: "claim_external_user_id"
  end

  def select_offence_category(name)
    select name, from: "claim_offence_category_description"
  end

  def select_offence_class(name)
    select name, from: "offence_class_description", autocomplete: false
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

  def attach_evidence(count: 1, document: '*')
    count ||= 1
    available_docs = Dir.glob "#{Rails.root}/spec/fixtures/files/#{document.gsub('.pdf','')}.pdf"
    available_docs[0...count].each do |path|
      drag_and_drop_file("dropzone", path)
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
end
