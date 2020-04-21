Then(/^I should be on the litigator new hardship claim page$/) do
  expect(@litigator_hardship_claim_form_page).to be_displayed
  @litigator_hardship_claim_form_page.wait_until_continue_button_visible
end

And("I enter {string} in the PPE total hardship fee field") do |value|
  @litigator_hardship_claim_form_page.hardship_fee.ppe_total.set(nil)
  value.chars.each do |char|
    @litigator_hardship_claim_form_page.hardship_fee.ppe_total.send_keys(char)
    wait_for_ajax
  end
end

And("I enter {string} in the net amount hardship fee field") do |value|
  @litigator_hardship_claim_form_page.hardship_fee.amount.set(nil)
  value.chars.each do |char|
    @litigator_hardship_claim_form_page.hardship_fee.amount.send_keys(char)
    wait_for_ajax
  end
end
