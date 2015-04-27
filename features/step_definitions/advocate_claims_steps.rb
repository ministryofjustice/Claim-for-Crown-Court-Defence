Given(/^I am a signed in advocate$/) do
  advocate = create(:advocate)
  visit new_user_session_path
  sign_in(advocate.user, 'password')
end

Given(/^I am on the new claim page$/) do
  create(:court, name: 'some court')
  create(:offence, offence_class: 'A', description: 'Murder')
  create(:document_type, description: 'Other')
  visit new_advocates_claim_path
end

When(/^I select a court and fill in the defendant details$/) do
  select('some court', from: 'claim_court_id')
  fill_in 'Case number', with: '123456'
  select('Murder', from: 'claim_offence_id')
  select('Guilty', from: 'claim_case_type')
  fill_in 'First name', with: 'Foo'
  fill_in 'Last name', with: 'Bar'
  fill_in 'Date of birth', with: '04/10/1980'
  fill_in 'claim_defendants_attributes_0_maat_reference', with: 'aaa1111'
  select 'Other', from: 'claim_documents_attributes_0_document_type_id'
  fill_in 'claim_documents_attributes_0_notes', with: 'Notes'
  attach_file(:claim_documents_attributes_0_document, 'features/examples/shorter_lorem.docx')
end

When(/^I submit the form$/) do
  click_on 'Submit'
end

Then(/^I should be redirected to the claim summary page$/) do
  claim = Claim.first
  expect(page.current_path).to eq(summary_advocates_claim_path(claim))
end

Then(/^I should see the claim total$/) do
  expect(page).to have_content('Total')
end

Given(/^I am on the claim summary page$/) do
  steps <<-STEPS
    Given I am a signed in advocate
      And I am on the new claim page
     When I select a court and fill in the defendant details
      And I submit the form
     Then I should be redirected to the claim summary page
      And I should see the claim total
  STEPS
end

Then(/^I should be on the claim confirmation page$/) do
  claim = Claim.first
  expect(page.current_path).to eq(confirmation_advocates_claim_path(claim))
end

Then(/^the claim should be submitted$/) do
  claim = Claim.first
  expect(claim).to be_submitted
end

When(/^I click the back button$/) do
  click_link 'Back'
end

Then(/^I should be on the claim edit form$/) do
  claim = Claim.first
  expect(page.current_path).to eq(edit_advocates_claim_path(claim))
end

Then(/^I should be on the claim summary page$/) do
  claim = Claim.first
  expect(page.current_path).to eq(summary_advocates_claim_path(claim))
end

Given(/^a claim exists$/) do
  create(:claim, advocate_id: Advocate.first.id)
end

When(/^I am on the claim edit page$/) do
  claim = Claim.first
  visit edit_advocates_claim_path(claim)
end
