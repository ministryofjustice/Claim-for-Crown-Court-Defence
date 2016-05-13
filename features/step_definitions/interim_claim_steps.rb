And(/^I enter (\d+) in the PPE total field$/) do |value|
  @interim_claim_form_page.interim_fee.ppe_total.set value
end

And(/^I enter (\d+) in the interim fee total field$/) do |value|
  @interim_claim_form_page.interim_fee.total.set value
end

And(/^I enter the effective PCMH date$/) do
  @interim_claim_form_page.interim_fee.effective_pcmh_date.set_date "2016-01-01"
end
