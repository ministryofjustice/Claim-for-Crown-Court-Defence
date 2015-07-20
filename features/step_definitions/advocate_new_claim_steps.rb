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
  create(:fee_type, :basic, description: 'Basic Fee')
  create(:fee_type, :basic, description: 'Other Basic Fee')
  create(:fee_type, :basic, description: 'Basic Fee with Modifer', quantity_modifier: -4)
  create(:fee_type, :basic, description: 'Basic Fee with dates attended required', quantity_modifier: -2, code: 'SAF')
  create(:expense_type, name: 'Travel')
  visit new_advocates_claim_path
end

Given(/^There are fee schemes in place$/) do
  Scheme.find_or_create_by(name: 'AGFS Fee Scheme 7', start_date: Date.parse('01/04/2011'), end_date: Date.parse('02/10/2011'))
  Scheme.find_or_create_by(name: 'AGFS Fee Scheme 8', start_date: Date.parse('03/10/2011'), end_date: Date.parse('31/03/2012'))
  Scheme.find_or_create_by(name: 'AGFS Fee Scheme 9', start_date: Date.parse('01/04/2012'), end_date: nil)
end

When(/^I click Add another representation order$/) do
  page.all('a.button-secondary.add_fields').select {|link| link.text == "Add another representation order"}.first.click
end

Then(/^I see (\d+) fields? for adding a rep order$/) do |number|
  page.all('.rep_order').count == number
end

When(/^I then choose to remove the additional rep order$/) do
  page.all('a', text: "Remove representation order").last.click
end

Given(/^I am creating a new claim$/) do
  visit new_advocates_claim_path
end

# NOTE: this step requires server to be running as it is js-reliant (i.e. cocoon)
When(/^I add (\d+) dates? attended for one of my "(.*?)" fees$/) do |number, fee_type |
  div_id = fee_type.downcase == "fixed" ? 'fees' : 'basic_fees'

  number.to_i.times do
  within "##{div_id}" do
    click_on "Add Date Attended"
  end
 end

  within "##{div_id}" do
    expect(page).to have_selector('.extra-data')
    index = 0
    all(:css, '.extra-data').each do |extra_data|
      within extra_data do
        expect(page).to have_content('Date attended (from)')
        expect(page).to have_selector('input')
        index += 1
      end
    end
    expect(index).to eq(number.to_i)
  end
end

When(/^I remove the fee$/) do
  within('#fees') do
    page.all('a', text: "Remove").first.click
  end
end

Then(/^the dates attended are also removed$/) do
  expect(within('#fees') { page.all('tr.extra-data.nested-fields') }.count).to eq 0
end

When(/^I fill in the claim details$/) do
  select('Guilty plea', from: 'claim_case_type')
  select('CPS', from: 'claim_prosecuting_authority')
  select('some court', from: 'claim_court_id')
  fill_in 'claim_case_number', with: '123456'
  select('A: Homicide and related grave offences', from: 'claim_offence_class_id')
  select('Murder', from: 'claim_offence_id')
  select('QC', from: 'claim_advocate_category')

  within '#defendants' do
    fill_in 'claim_defendants_attributes_0_first_name', with: 'Foo'
    fill_in 'claim_defendants_attributes_0_last_name', with: 'Bar'

    fill_in 'claim_defendants_attributes_0_date_of_birth_3i', with: '04'
    fill_in 'claim_defendants_attributes_0_date_of_birth_2i', with: '10'
    fill_in 'claim_defendants_attributes_0_date_of_birth_1i', with: '1980'

    fill_in 'claim_defendants_attributes_0_representation_orders_attributes_0_maat_reference', with: 'aaa1111'

    date = rand(1..10).days.ago
    fill_in 'claim_defendants_attributes_0_representation_orders_attributes_0_representation_order_date_3i', with: date.strftime('%d')
    fill_in 'claim_defendants_attributes_0_representation_orders_attributes_0_representation_order_date_2i', with: date.strftime('%m')
    fill_in 'claim_defendants_attributes_0_representation_orders_attributes_0_representation_order_date_1i', with: date.strftime('%Y')

    choose 'Crown Court'
  end

  within '#basic_fees' do
    fill_in 'claim_basic_fees_attributes_0_quantity', with: 1
    fill_in 'claim_basic_fees_attributes_0_rate', with: 0.5
    fill_in 'claim_basic_fees_attributes_1_quantity', with: 1
    fill_in 'claim_basic_fees_attributes_1_rate', with: 0.5
  end

  within '#expenses' do
    select 'Travel', from: 'claim_expenses_attributes_0_expense_type_id'
    fill_in 'claim_expenses_attributes_0_location', with: 'London'
    fill_in 'claim_expenses_attributes_0_quantity', with: 1
    fill_in 'claim_expenses_attributes_0_rate', with: 40
  end

  within 'table#evidence-checklist' do
    element = find('td label', text: "Representation Order")
    checkbox_id = element[:for]
    check checkbox_id
  end

  attach_file(:claim_documents_attributes_0_document, 'features/examples/longer_lorem.pdf')
end

When(/^I make the claim invalid$/) do
  fill_in 'claim_case_number', with: ''
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

When(/^I submit to LAA$/) do
  click_on 'Submit to LAA'
end

When(/^I save to drafts$/) do
  click_on 'Save to drafts'
end

Then(/^I should be redirected to the claim confirmation page$/) do
  claim = Claim.first
  expect(page.current_path).to eq(confirmation_advocates_claim_path(claim))
end

Then(/^I should be redirected back to the claim form with error$/) do
  expect(page).to have_content('Claim for Advocate Graduated Fees')
  expect(page).to have_content(/\d+ errors? prohibited this claim from being saved:/)
  expect(page).to have_content("Advocate can't be blank")
end


Then(/^I should see the claim totals$/) do
  expect(page).to have_content("Fees total: £1.00")
  expect(page).to have_content("Expenses total: £40.00")
  expect(page).to have_content("Total: £41.00")
end

Given(/^I am on the claim confirmation page$/) do
  steps <<-STEPS
    Given I am a signed in advocate
      And I am on the new claim page
     When I fill in the claim details
      And I submit to LAA
     Then I should be redirected to the claim confirmation page
      And I should see the claim totals
  STEPS
end

When(/^I click the back button$/) do
  click_link 'Back'
end

Then(/^I should be on the claim edit form$/) do
  claim = Claim.first
  expect(page.current_path).to eq(edit_advocates_claim_path(claim))
end

Then(/^I should be on the claim confirmation page$/) do
  claim = @claim || Claim.first
  expect(page.current_path).to eq(confirmation_advocates_claim_path(claim))
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

Then(/^I should be redirected to the claims list page$/) do
  expect(page.current_path).to eq(advocates_claims_path)
end

Then(/^I should see my claim under drafts$/) do
  claim = Claim.first
  within '#draft' do
    expect(page).to have_selector("#claim_#{claim.id}")
  end
end

When(/^I clear the form$/) do
  click_on 'Clear form'
end

Then(/^I should be redirected to the new claim page$/) do
  expect(page.current_path).to eq(new_advocates_claim_path)
end

Then(/^the claim should be in a "(.*?)" state$/) do |state|
  claim = Claim.first
  expect(claim.state).to eq(state)
end

Then(/^I should see errors$/) do
  expect(page).to have_content(/\d+ errors? prohibited this claim from being saved/)
end

Then(/^no claim should be created$/) do
  expect(Claim.count).to be_zero
end

When(/^I change the case number$/) do
  fill_in 'claim_case_number', with: '543211234'
end

Then(/^the case number should reflect the change$/) do
  claim = Claim.first
  expect(claim.case_number).to eq('543211234')
end

When(/^I fill in an additional fee type that is subjected to a modifer$/) do
  within '#basic_fees' do
    fill_in 'claim_basic_fees_attributes_2_quantity', with: 6
    fill_in 'claim_basic_fees_attributes_2_rate', with: 1
  end
end

Then(/^I should see the claim totals accounting for modifier$/) do
  expect(page).to have_content("Fees total: £3.00")
  expect(page).to have_content("Expenses total: £40.00")
  expect(page).to have_content("Total: £43.00")
end
