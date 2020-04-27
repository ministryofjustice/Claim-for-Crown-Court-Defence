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

Then(/^the hardship fee amount should be populated with '(\d+\.\d+)'$/) do |amount|
  patiently do
    expect(@litigator_hardship_claim_form_page.hardship_fee).to have_amount
    expect(@litigator_hardship_claim_form_page.hardship_fee.amount.value).to eql amount
  end
end
