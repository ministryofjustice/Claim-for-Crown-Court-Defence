Given(/^I fill in the first day of trial with (\d+)\-(\w+)\-(\d+)$/) do |day, month, year|
  fill_in 'claim_first_day_of_trial_dd', with: day
  fill_in 'claim_first_day_of_trial_mm', with: month
  fill_in 'claim_first_day_of_trial_yyyy', with: year
end


Then(/^the claim's first day of trial should be (\d+)$/) do |expected_date|
  date = Date.parse(expected_date)
  claim = Claim::BaseClaim.first

  expect(claim.first_day_of_trial).to eq(date)
end
