class UserHomePage < SitePrism::Page
  element :start_a_claim, "div.claims-actions > a.button-start"
  element :your_claims_link, "div.breadcrumbs > ol > li:nth-of-type(1) > a"

  sections :claims, "table.report > tbody > tr" do
    element :case_number, "a.js-test-case-number-link"
    element :state, "span.state"
    element :claimed, "td.claimed-amount"
    element :view_messages, "td.messages > a"
  end

  def claim_for(case_number)
    claims.select { |claim| claim.case_number.text == case_number } .first
  end

  def includes_all_claims?(comma_list)
    list_to_array(comma_list).each do |case_number|
      return false unless case_numbers.include?(case_number)
    end

    true
  end

  def case_numbers
    claims.map { |claim| claim.case_number.text }
  end

  def list_to_array(comma_separated_list)
    comma_separated_list.split(',').map(&:strip)
  end
end
