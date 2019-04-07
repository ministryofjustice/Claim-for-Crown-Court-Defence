Then(/^I should be on the litigator new interim claim page$/) do
  expect(@litigator_interim_claim_form_page).to be_displayed
  @litigator_interim_claim_form_page.wait_until_continue_button_visible
end

And(/^I select an interim fee type of '(.*)'$/) do |name|
  @litigator_interim_claim_form_page.interim_fee.select_fee_type(name)
  wait_for_ajax
end

And(/^I enter the effective PCMH date\s*(.*?)$/) do |date|
  date = date.present? ? date : "2016-04-01"
  @litigator_interim_claim_form_page.interim_fee.effective_pcmh_date.set_date date
end

And(/^I enter the trial start date\s*(.*?)$/) do |date|
  date = date.present? ? date : scheme_date_for('lgfs')
  @litigator_interim_claim_form_page.interim_fee.first_day_of_trial.set_date date
end

And(/^I enter the retrial start date\s*(.*?)$/) do |date|
  date = date.present? ? date : scheme_date_for('lgfs')
  @litigator_interim_claim_form_page.interim_fee.retrial_started_at.set_date date
end

And(/^I enter the legal aid transfer date\s*(.*?)$/) do |date|
  date = date.present? ? date : scheme_date_for('lgfs')
  @litigator_interim_claim_form_page.interim_fee.legal_aid_transfer_date.set_date date
end

And(/^I enter the first trial concluded date\s*(.*?)$/) do |date|
  date = date.present? ? date : scheme_date_for('lgfs')
  @litigator_interim_claim_form_page.interim_fee.trial_concluded_at.set_date date
end

And("I enter {string} in the estimated trial length field") do |value|
  @litigator_interim_claim_form_page.interim_fee.estimated_trial_length.set nil
  value.chars.each do |char|
    @litigator_interim_claim_form_page.interim_fee.estimated_trial_length.send_keys(char)
    wait_for_ajax
  end
end

And("I enter {string} in the estimated retrial length field") do |value|
  @litigator_interim_claim_form_page.interim_fee.retrial_estimated_length.set nil
  value.chars.each do |char|
    @litigator_interim_claim_form_page.interim_fee.retrial_estimated_length.send_keys(char)
    wait_for_ajax
  end
end

And("I enter {string} in the PPE total interim fee field") do |value|
  @litigator_interim_claim_form_page.interim_fee.ppe_total.set nil
  value.chars.each do |char|
    @litigator_interim_claim_form_page.interim_fee.ppe_total.send_keys(char)
    wait_for_ajax
  end
end

And(/^I enter '(.*)' as the warrant issued date$/) do |date|
  @litigator_interim_claim_form_page.interim_fee.warrant_issued_date.set_date date
end

And(/^I enter '(.*)' as the warrant executed date$/) do |date|
  @litigator_interim_claim_form_page.interim_fee.warrant_executed_date.set_date date
end

Then(/^I enter '(\d+\.\d+)' in the interim fee total field$/) do |amount|
  @litigator_interim_claim_form_page.interim_fee.amount.set amount
end

Then(/^I should see interim fee types applicable to a '(.*?)'$/) do |name|
  expect(@litigator_interim_claim_form_page.interim_fee.fee_type_select_names).to include(*expected_interim_fees_for(name))
end

Then("the interim fee amount should be populated with {string}") do |amount|
  patiently do
    expect(@litigator_interim_claim_form_page.interim_fee).to have_amount
    expect(@litigator_interim_claim_form_page.interim_fee.amount.value).to eql amount.to_s
  end
end

Then(/^the interim fee should have its price_calculated value set to true$/) do
  claim = Claim::BaseClaim.find(@litigator_interim_claim_form_page.claim_id)
  expect(claim.interim_fee.price_calculated).to eql true
end

def expected_interim_fees_for(case_type_name)
  expected = ['Disbursement only', 'Warrant']
  expected += ['Effective PCMH', 'Trial start'] if case_type_name.casecmp('trial').eql?(0)
  expected += ['Retrial start','Retrial new solicitor'] if case_type_name.casecmp('retrial').eql?(0)
end
