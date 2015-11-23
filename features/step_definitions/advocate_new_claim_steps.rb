Given(/^There are other advocates in my chamber$/) do
  FactoryGirl.create(:advocate,
        chamber: @advocate.chamber,
        user: FactoryGirl.create(:user, first_name: 'John', last_name: 'Doe'),
        supplier_number: 'AC135')
  FactoryGirl.create(:advocate,
        chamber: @advocate.chamber,
        user: FactoryGirl.create(:user, first_name: 'Joe', last_name: 'Blow'),
        supplier_number: 'XY455')
end

Given(/^I am on the new claim page$/) do
  create(:court, name: 'some court')
  create(:offence_class, description: 'A: Homicide and related grave offences')
  create(:offence, description: 'Murder')
  create(:fee_type, :basic, description: 'Basic Fee', code: 'BAF')
  create(:fee_type, :basic, description: 'Other Basic Fee')
  create(:fee_type, :basic, description: 'Basic Fee with dates attended required', code: 'SAF')
  create(:fee_type, :fixed, description: 'Fixed Fee example')
  create(:fee_type, :misc,  description: 'Miscellaneous Fee example')
  create(:expense_type, name: 'Travel')
  visit new_advocates_claim_path
end

Given(/^There are case types in place$/) do
  load "#{Rails.root}/db/seeds/case_types.rb"
  CaseType.find_or_create_by!(name: 'Fixed fee', is_fixed_fee: true)
end

When(/^I click Add Another Representation Order$/) do
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

# NOTE: this step is js-reliant (i.e. cocoon)
When(/^I add (\d+) dates? attended for one of my "(.*?)" fees$/) do |number, fee_type|
  fee_div = fee_type_to_id(fee_type)
  number.to_i.times do
  within fee_div do
    click_on 'Add date(s)'
    wait_for_ajax
  end
 end
end

Given(/^I update the claim to be of casetype "(.*?)"$/) do |case_type|
  @claim.update(case_type: CaseType.find_by(name: case_type) )
end

When(/^I have one fee of type "(.*?)"$/) do |fee_type|
  @claim.fees.destroy_all
  FactoryGirl.create(:fee, fee_type.to_sym, claim: @claim)
end

When(/^I have (\d+) dates attended for my one fee$/) do |number|
  number.to_i.times do |i|
    FactoryGirl.create(:date_attended, attended_item: @claim.fees.first, date: 12.days.ago, date_to: 2.days.ago)
  end
end

Then(/^I should see (\d+) dates attended fields amongst "(.*?)" fees$/) do |number, fee_type|
  within fee_type_to_id(fee_type) do
    expect(page).to have_content('Date attended (from)', count: number)
  end
end

When(/^I click remove fee for "(.*?)"$/) do |fee_type|
  within fee_type_to_id(fee_type) do
    node = page.all('a', text: "Remove").first
    node.click
  end
end

Then(/^I should not see any dates attended fields for "(.*?)" fees$/) do |fee_type|
  within fee_type_to_id(fee_type) do
    expect(page).not_to have_content('Date attended (from)', wait: 5)
  end
end

Then(/^the dates attended are( not)? saved for "(.*?)"$/) do |negation, fee_type|
  true_or_false = negation.nil? ? true : negation.gsub(/\s+/,'').downcase == 'not' ? false : true
  expect(@claim.__send__("#{fee_type}_fees").count > 0).to eql true_or_false
end

Given(/^I am creating a "(.*?)" claim$/) do |case_type|
  select2 case_type, from: 'claim_case_type_id'
end

When(/^I fill in the certification details and submit/) do
  check 'certification_main_hearing'
  click_on 'Certify and submit claim'
end

Given(/^I add dates attended for the first miscellaneous fee$/) do
  within '#misc-fees' do
    click_on 'Add date(s)'
  end
end

Given(/^I fill in an invalid date from$/) do
  save_and_open_page
  fill_in 'claim_misc_fees_attributes_0_dates_attended_attributes_0_date_dd', with: 32
  fill_in 'claim_misc_fees_attributes_0_dates_attended_attributes_0_date_mm', with: 01
  fill_in 'claim_misc_fees_attributes_0_dates_attended_attributes_0_date_yyy', with: 1832
end

When(/^I fill in the claim details(.*)$/) do |details|
  select('Guilty plea', from: 'claim_case_type_id')
  select('some court', from: 'claim_court_id')
  fill_in 'claim_case_number', with: 'A12345678'
  fill_in 'claim_first_day_of_trial_dd', with: 5.days.ago.day.to_s
  fill_in 'claim_first_day_of_trial_mm', with: 5.days.ago.month.to_s
  fill_in 'claim_first_day_of_trial_yyyy', with: 5.days.ago.year.to_s
  fill_in 'claim_trial_concluded_at_dd', with: 2.days.ago.day.to_s
  fill_in 'claim_trial_concluded_at_mm', with: 2.days.ago.month.to_s
  fill_in 'claim_trial_concluded_at_yyyy', with: 2.days.ago.year.to_s
  fill_in 'claim_estimated_trial_length', with: 1
  fill_in 'claim_actual_trial_length', with: 1
  murder_offence_id = Offence.find_by(description: 'Murder').id.to_s
  first('#claim_offence_id', visible: false).set(murder_offence_id)
  select('QC', from: 'claim_advocate_category')

  within '#defendants' do
    fill_in 'claim_defendants_attributes_0_first_name', with: 'Foo'
    fill_in 'claim_defendants_attributes_0_last_name', with: 'Bar'

    fill_in 'claim_defendants_attributes_0_date_of_birth_dd', with: '04'
    fill_in 'claim_defendants_attributes_0_date_of_birth_mm', with: '10'
    fill_in 'claim_defendants_attributes_0_date_of_birth_yyyy', with: '1980'

    fill_in 'claim_defendants_attributes_0_representation_orders_attributes_0_maat_reference', with: '4561239693'

    date = rand(10..20).days.ago
    fill_in 'claim_defendants_attributes_0_representation_orders_attributes_0_representation_order_date_dd', with: date.strftime('%d')
    fill_in 'claim_defendants_attributes_0_representation_orders_attributes_0_representation_order_date_mm', with: date.strftime('%m')
    fill_in 'claim_defendants_attributes_0_representation_orders_attributes_0_representation_order_date_yyyy', with: date.strftime('%Y')

    choose 'Crown Court'
  end

  unless details == ' but add no fees or expenses' # preceeding space is required for match
    within '#basic-fees' do
      fill_in 'claim_basic_fees_attributes_0_quantity', with: 1
      fill_in 'claim_basic_fees_attributes_0_amount', with: 50
      fill_in 'claim_basic_fees_attributes_1_quantity', with: 1
      fill_in 'claim_basic_fees_attributes_1_amount', with: 50
    end

    within '#expenses' do
      select 'Travel', from: 'claim_expenses_attributes_0_expense_type_id'
      fill_in 'claim_expenses_attributes_0_location', with: 'London'
      fill_in 'claim_expenses_attributes_0_quantity', with: 1
      fill_in 'claim_expenses_attributes_0_rate', with: 40
    end
  end

  within 'fieldset#evidence-checklist' do
    element = find('div label', text: "Representation order")
    checkbox_id = element[:for]
    check checkbox_id
  end
end

When(/^I make the claim invalid$/) do
  fill_in 'claim_case_number', with: ''
end

When(/^I submit to LAA$/) do
  click_on 'Submit to LAA'
end

When(/^I save to drafts$/) do
  click_on 'Save to drafts'
end

Then(/^the claim should be saved in draft state$/) do
  expect(Claim.where(state: 'draft').count).to eq 1
end

Then(/^I should be redirected to the claim confirmation page$/) do
  claim = Claim.first
  expect(page.current_path).to eq(confirmation_advocates_claim_path(claim))
end

Then(/^I should be redirected to the claim certification page$/) do
  claim = Claim.first
  expect(page.current_path).to eq(new_advocates_claim_certification_path(claim))
end

Then(/^I should be redirected back to the claim form with error$/) do
  expect(page).to have_content('Claim for advocate graduated fees')
  expect(page).to have_content(/This claim has \d+ errors?/)
  expect(page).to have_content("Choose an advocate")
end


Then(/^I should see the claim totals$/) do
  expect(page).to have_content("Fees total: £100.00")
  expect(page).to have_content("Expenses total: £40.00")
  expect(page).to have_content("Total: £164.50")
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

# Given(/^it has a case type of "(.*?)"$/) do |case_type|
#   Claim.first.case_type = CaseType.find_by(name: case_type)
# end

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
  expect(page).to have_content(/This claim has \d+ errors?/)
end

Then(/^I should not see errors$/) do
  expect(page).not_to have_content(/This claim has \d+ errors?/)
end

Then(/^no claim should be submitted$/) do
  expect(Claim.where(state: 'submitted').count).to be_zero
end

When(/^I change the case number$/) do
  fill_in 'claim_case_number', with: 'A87654321'
end

Then(/^the case number should reflect the change$/) do
  claim = Claim.first
  expect(claim.case_number).to eq('A87654321')
end

When(/^I add a fixed fee$/) do
    within '#fixed-fees' do
      fill_in 'claim_fixed_fees_attributes_0_quantity', with: 1
      fill_in 'claim_fixed_fees_attributes_0_amount', with: 100.00
      select 'Fixed Fee example', from: 'claim_fixed_fees_attributes_0_fee_type_id'
    end
end

Then(/^I should see the claim totals accounting for only the fixed fee$/) do
  expect(page).to have_content("Fees total: £100.00")
end

When(/^I add a miscellaneous fee$/) do
    within '#misc-fees' do
      fill_in 'claim_misc_fees_attributes_0_quantity', with: 1
      fill_in 'claim_misc_fees_attributes_0_amount', with: 200.00
      select 'Miscellaneous Fee example', from: 'claim_misc_fees_attributes_0_fee_type_id'
    end
end

Then(/^I should see the claim totals accounting for the miscellaneous fee$/) do
  expect(page).to have_content("Fees total: £300.00")
end

When(/^I select a Case Type of "(.*?)"$/) do |case_type|
  select case_type, from: 'claim_case_type_id'
end

When(/^I select2 a Case Type of "(.*?)"$/) do |case_type|
  select2 case_type, from: 'claim_case_type_id'
end

Then(/^There should not be any Initial Fees saved$/) do
  # note: cannot rely on size/count since all basic fees are
  #       instantiated as empty but existing records per claim.
  expect(Claim.last.calculate_fees_total(:basic).to_f).to eql(0.0)
end

# Then(/^There should not be any Miscellaneous Fees Saved$/) do
#   expect(Claim.last.misc_fees.size).to eql(0)
# end

Then(/^There should be a Miscellaneous Fee Saved$/) do
  expect(Claim.last.misc_fees.size).to eql(1)
end


Then(/^There should not be any Fixed Fees saved$/) do
  expect(Claim.last.fixed_fees.size).to eql(0)
end

Then(/^I should( not)? be able to view "(.*?)"$/i) do |have, content|
  to_or_not_to = have.nil? ? 'to' : have.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(to_or_not_to).call have_content(content)
end

Then(/^I should see a Basic Fee quantity of exactly one$/) do
  expect(page).to have_field('claim_basic_fees_attributes_0_quantity', with: 1)
end

Given(/^I fill in an Initial Fee$/) do
  within '#basic-fees' do
    fill_in 'claim_basic_fees_attributes_0_quantity', with: 2
    fill_in 'claim_basic_fees_attributes_0_amount', with: 1.5
  end
end

Given(/^I fill in a Miscellaneous Fee$/) do
  within '#misc-fees' do
    select 'Miscellaneous Fee example', from: 'claim_misc_fees_attributes_0_fee_type_id'
    fill_in 'claim_misc_fees_attributes_0_quantity', with: 2
    fill_in 'claim_misc_fees_attributes_0_amount', with: 3.00
  end
end

Given(/^I fill in a Fixed Fee$/) do
  within '#fixed-fees' do
    select 'Fixed Fee example', from: 'claim_fixed_fees_attributes_0_fee_type_id'
    fill_in 'claim_fixed_fees_attributes_0_quantity', with: 2
    fill_in 'claim_fixed_fees_attributes_0_amount', with: 3.00
  end
end

Given(/^I fill in a Fixed Fee using select2$/) do
  within '#fixed-fees' do
    # select2 'Fixed Fee example', from: 'claim_fixed_fees_attributes_0_fee_type_id' # does not work
    fill_in 'claim_fixed_fees_attributes_0_quantity', with: 2
    fill_in 'claim_fixed_fees_attributes_0_amount', with: 3.00
  end
end

Given(/^a non\-fixed\-fee claim exists with basic and miscellaneous fees$/) do
  claim = create(:draft_claim, case_type_id: CaseType.by_type('Trial').id, advocate_id: Advocate.first.id)
  create(:fee, :basic, claim: claim, quantity: 3, amount: 7.0)
  create(:fee, :misc,  claim: claim, quantity: 2, amount: 5.0)
end

# local helpers
# -----------------
def fee_type_to_id(fee_type)
  div_id = fee_type.downcase == "fixed" ? 'fixed-fees' : 'misc-fees'
  "##{div_id}"
end