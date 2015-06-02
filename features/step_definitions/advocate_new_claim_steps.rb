Given(/^There are other advocates in my chamber$/) do
  FactoryGirl.create(:advocate,
        chamber: @advocate.chamber,
        user: FactoryGirl.create(:user, first_name: 'John', last_name: 'Doe'),
        account_number: 'AC135')
  FactoryGirl.create(:advocate,
        chamber: @advocate.chamber,
        user: FactoryGirl.create(:user, first_name: 'Joe', last_name: 'Blow'),
        account_number: 'XY455')
end

Given(/^I am on the new claim page$/) do
  create(:court, name: 'some court')
  create(:offence_class, description: 'A: Homicide and related grave offences')
  create(:offence, description: 'Murder')
  create(:document_type, description: 'Other')
  create(:fee_type, description: 'Basic Fee')
  create(:expense_type, name: 'Travel')
  visit new_advocates_claim_path
end

When(/^I fill in the claim details$/) do
  select('Guilty plea', from: 'claim_case_type')
  select('CPS', from: 'claim_prosecuting_authority')
  select('some court', from: 'claim_court_id')
  fill_in 'Case number', with: '123456'
  select('A: Homicide and related grave offences', from: 'claim_offence_class_id')
  select('Murder', from: 'claim_offence_id')
  select('Qc alone', from: 'claim_advocate_category')

  fill_in 'First name', with: 'Foo'
  fill_in 'Last name', with: 'Bar'
  fill_in 'Date of birth', with: '04/10/1980'
  fill_in 'claim_defendants_attributes_0_maat_reference', with: 'aaa1111'

  within '#fees' do
    select 'Basic Fee', from: 'claim_fees_attributes_0_fee_type_id'
    fill_in 'Quantity', with: 1
    fill_in 'Rate', with: 1
    fill_in 'Amount', with: 20
  end

  within '#expenses' do
    select 'Travel', from: 'claim_expenses_attributes_0_expense_type_id'
    fill_in 'Location', with: 'London'
    fill_in 'Quantity', with: 1
    fill_in 'Rate', with: 1
    fill_in 'Hours', with: 1
    fill_in 'Amount', with: 40
  end

  select 'Other', from: 'claim_documents_attributes_0_document_type_id'
  fill_in 'claim_documents_attributes_0_notes', with: 'Notes'
  attach_file(:claim_documents_attributes_0_document, 'features/examples/longer_lorem.pdf')
end

When(/^I select offence class "(.*?)"$/) do |offence_class|
  select(offence_class, from: 'claim_offence_class_id')
end

Then(/^the Offence category does NOT contain "(.*?)"$/) do |invalid_offence_category|
  expect(page).not_to have_content(invalid_offence_category)
end

Then(/^the Offence category does contain "(.*?)"$/) do |valid_offence_category|
  expect(page).to have_content(valid_offence_category)
end

When(/^I submit the form$/) do
  click_on 'Submit'
end

Then(/^I should be redirected to the claim summary page$/) do
  claim = Claim.first
  expect(page.current_path).to eq(summary_advocates_claim_path(claim))
end

Then(/^I should be redirected back to the claim form with error$/) do
  expect(page).to have_content('Claim for Advocate Graduated Fees')
  expect(page).to have_content(/\d+ errors? prohibited this claim from being saved:/)
  expect(page).to have_content("Advocate can't be blank")
end


Then(/^I should see the claim totals$/) do
  expect(page).to have_content("Fees total: £20.00")
  expect(page).to have_content("Expenses total: £40.00")
  expect(page).to have_content("Total: £60.00")
end

Given(/^I am on the claim summary page$/) do
  steps <<-STEPS
    Given I am a signed in advocate
      And I am on the new claim page
     When I fill in the claim details
      And I submit the form
     Then I should be redirected to the claim summary page
      And I should see the claim totals
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
  claim = @claim || Claim.first
  expect(page.current_path).to eq(summary_advocates_claim_path(claim))
end

Given(/^a claim exists$/) do
  create(:claim, advocate_id: Advocate.first.id)
end

Given(/^a claim exists with state "(.*?)"$/) do |claim_state|
  @claim = case claim_state
           when "draft"
             create(:claim, advocate_id: Advocate.first.id)
           else
             create(:claim, advocate_id: Advocate.first.id)
           end
end

Then(/^the claim should be in state "(.*?)"$/) do |claim_state|
  @claim.reload
  expect(@claim.state).to eq(claim_state)
end

When(/^I am on the claim edit page$/) do
  claim = Claim.first
  visit edit_advocates_claim_path(claim)
end


Then(/^I can view a select of all advocates in my chamber$/) do
  expect(page).to have_selector('select#claim_advocate_id')
  expect(page).to have_content('Doe, John: AC135')
  expect(page).to have_content('Blow, Joe: XY455')
end

When(/^I select Advocate name "(.*?)"$/) do |advocate_name|
  select(advocate_name, from: 'claim_advocate_id')
end

