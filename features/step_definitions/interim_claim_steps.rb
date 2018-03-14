Then(/^I should be on the litigator new interim claim page$/) do
  expect(@interim_claim_form_page).to be_displayed
  @interim_claim_form_page.wait_until_continue_button_visible
end

And(/^I select an interim fee type of '(.*)'$/) do |name|
  @interim_claim_form_page.interim_fee.select_fee_type(name)
end

And(/^I enter (\d+) in the PPE total field$/) do |value|
  @interim_claim_form_page.interim_fee.ppe_total.set value
end

And(/^I enter (\d+) in the interim fee total field$/) do |value|
  @interim_claim_form_page.interim_fee.total.set value
end

And(/^I enter the effective PCMH date$/) do
  @interim_claim_form_page.interim_fee.effective_pcmh_date.set_date "2016-01-01"
end

Then(/^I should see interim fee types applicable to a '(.*?)'$/) do |name|
  expect(@interim_claim_form_page.interim_fee.fee_type_select_names).to include(*expected_interim_fees_for(name))
end

def expected_interim_fees_for(case_type_name)
  expected = ['Disbursement only', 'Warrant']
  expected += ['Effective PCMH', 'Trial start'] if case_type_name.casecmp('trial').eql?(0)
  expected += ['Retrial start','Retrial new solicitor'] if case_type_name.casecmp('retrial').eql?(0)
end
