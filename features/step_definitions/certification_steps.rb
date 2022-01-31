Then('I should be on the certification page') do
  expect(@certification_page).to be_displayed
end

Then('certified by should be set to current user name') do
  expect(@certification_page.certified_by.value).to eql(@current_user.name)
end

Then('certification date should be set to today') do
  dd, mm, yyyy = Time.current.strftime('%-d-%-m-%Y').split('-')
  expect(@certification_page.certification_date.day.value).to eql(dd)
  expect(@certification_page.certification_date.month.value).to eql(mm)
  expect(@certification_page.certification_date.year.value).to eql(yyyy)
end

When('I check “I attended the main hearing”') do
  @certification_page.attended_main_hearing.click
end

When('I fill in {string} as the certification date day') do |day|
  @certification_page.certification_date.day.set(day)
end

When('I fill in todays date as the certification date') do
  dd, mm, yyyy = Time.current.strftime('%-d-%-m-%Y').split('-')
  @certification_page.certification_date.day.set(dd)
  @certification_page.certification_date.month.set(mm)
  @certification_page.certification_date.year.set(yyyy)
end

When('I click Certify and submit claim') do
  allow(Aws::SNS::Client).to receive(:new).and_return Aws::SNS::Client.new(region: 'eu-west-1', stub_responses: true)
  @certification_page.wait_until_certify_and_submit_claim_visible
  patiently do
    @certification_page.certify_and_submit_claim.click
  end
end
