When(/^I visit the detailed view for a claim$/) do
  first('div.claim-controls').click_link('Detail')
end

Then(/^I should see associated evidence from the provider$/) do
  expect(first('#evidence-list')).to have_link 'View'
end