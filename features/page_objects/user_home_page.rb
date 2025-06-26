class UserHomePage < BasePage
  element :start_a_claim, "a.govuk-button--start"
  element :your_claims_link, "nav.govuk-service-navigation__wrapper > ul > li:nth-of-type(1) > strong > a"

  sections :claims, "table.govuk-table > tbody > tr" do
    element :case_number, "a.js-test-case-number-link"
    element :state, "strong.govuk-tag"
    element :claimed, "td[data-label='Claimed']"
    element :view_messages, "td[data-label='Messages'] > a"
    element :error_message, '.error-message'
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

  def error_messages
    claims.map { |claim | claim.error_message.text }
  end
end
