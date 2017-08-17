class AllocationPage < SitePrism::Page
  include SelectHelper

  set_url "/case_workers/admin"

  element :notice, "#notice-summary-heading"

  element :allocate, "input.button.allocation-submit"

  sections :allocations, "table.report > tbody > tr" do
    element :case_number, "td:nth-of-type(2) span.js-test-case-number"
  end

  def select_case_worker(name)
    select name, from: "allocation_case_worker_id"
  end

  def select_claims(case_numbers)
    wait_for_ajax
    list_to_array(case_numbers).each { |case_number| find(:xpath, "//td/a[contains(., '#{case_number}')]/../../td/input").click() }
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
