Given(/^I have a claim$/) do
  advocate = Advocate.first
  @claim = create(:submitted_claim, advocate: advocate, notes: 'Hello world')
end

When(/^I visit the claim's detail page$/) do
  visit advocates_claim_path(@claim)
end

Then(/^I should not see the caseworker notes$/) do
  expect(page).to_not have_content('Hello world')
end

Given(/^a claim has been assiged to me$/) do
  case_worker = CaseWorker.first
  @claim = create(:submitted_claim, notes: 'Hello world')
  case_worker.claims << @claim
end

When(/^I visit the case worker claim's detail page$/) do
  visit case_workers_claim_path(@claim)
end

Then(/^I should be able to see the caseworker notes$/) do
  expect(page).to have_content('Hello world')
end

Then(/^I update the caseworker notes$/) do
  fill_in 'claim_notes', with: 'Lorem ipsum'
  click_button 'Update notes'
end

Then(/^the notes will be saved$/) do
  expect(page).to have_content('Lorem ipsum')
end