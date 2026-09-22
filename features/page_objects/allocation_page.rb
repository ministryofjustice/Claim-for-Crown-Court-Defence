class AllocationPage < BasePage
  include SelectHelper

  set_url "/case_workers/admin"

  element :quantity_to_allocate, '#quantity-to-allocate-field'

  element :allocate, "button.govuk-button.allocation-submit"

  section :auto_caseworker, CommonAutocomplete, "#cc-caseworker"

  sections :allocations, "table.report > tbody > tr" do
    element :case_number, "td:nth-of-type(2) span.js-test-case-number"
  end

  def select_claims(case_numbers)
    wait_for_ajax
    list_to_array(case_numbers).each do |case_number|
      check("Select case #{case_number}", allow_label_click: true, visible: :all)
    end
  end

  def includes_any_cases?(comma_list)
    list_to_array(comma_list).each do |case_number|
      return true if case_numbers.include?(case_number)
    end

    false
  end

  def includes_all_cases?(comma_list)
    list_to_array(comma_list).each do |case_number|
      return false unless case_numbers.include?(case_number)
    end

    true
  end

  def case_numbers
    allocations.map { |allocation| allocation.case_number.text }
  end

  def list_to_array(comma_separated_list)
    comma_separated_list.split(',').map(&:strip)
  end
end
