Given(/^certification types are seeded$/) do
  load("#{Rails.root}/db/seeds/certification_types.rb")
end

Given(/^There are other advocates in my provider$/) do
  FactoryGirl.create(:external_user,
        :advocate,
        provider: @advocate.provider,
        user: FactoryGirl.create(:user, first_name: 'John', last_name: 'Doe'),
        supplier_number: 'AC135')
  FactoryGirl.create(:external_user,
        :advocate,
        provider: @advocate.provider,
        user: FactoryGirl.create(:user, first_name: 'Joe', last_name: 'Blow'),
        supplier_number: 'XY455')
end

Given(/^I am on the new claim page$/) do
  create(:court, name: 'some court')
  offence_class = OffenceClass.find_by(class_letter: "A")
  if offence_class.nil?
    create(:offence_class, class_letter: 'A', description: 'A: Homicide and related grave offences')
  else
    offence_class.update(description: 'A: Homicide and related grave offences')
  end
  create(:offence, description: 'Murder')
  create(:basic_fee_type, description: 'Basic Fee', code: 'BAF')
  create(:basic_fee_type, description: 'Other Basic Fee')
  create(:basic_fee_type, description: 'Basic Fee with dates attended required', code: 'SAF')
  create(:fixed_fee_type, description: 'Fixed Fee example')
  create(:misc_fee_type,  description: 'Miscellaneous Fee example')
  create(:expense_type, name: 'Travel')
  visit new_advocates_claim_path
end

Given(/^There are case types in place$/) do
  load "#{Rails.root}/db/seeds/case_types.rb"
  FactoryGirl.create :case_type, :fixed_fee
end

When(/^I click Add another defendant$/) do
  within('.defendants') do
    page.all('a.add_fields').select {|link| link.text == "Add another defendant"}.first.click
  end
end

Then(/^I see (\d+) defendant sections?$/) do |number|
  within('.defendants') do
    expect(page.all('.js-test-defendant').count).to eq(number.to_i)
  end
end

When(/^I choose to remove the additional defendant$/) do
  within('.defendants') do
    page.all('a', text: "Remove defendant").last.click
  end
end

When(/^I click Add Another Representation Order$/) do
  within('.defendants') do
    page.all('a.add_fields').select {|link| link.text == "Add another representation order"}.first.click
  end
end

Then(/^I see (\d+) fields? for adding a rep order$/) do |number|
  within('.defendants') do
    expect(page.all('.js-test-rep-order').count).to eq(number.to_i)
  end
end

When(/^I choose to remove the additional rep order$/) do
  within('.defendants') do
    page.all('a', text: "Remove representation order").last.click
  end
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
  type_of_fee_to_create = "#{fee_type}_fee".to_sym
  FactoryGirl.create(type_of_fee_to_create, claim: @claim)
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
    wait_for_ajax(10)
  end
end

Then(/^I should not see any dates attended fields for "(.*?)" fees$/) do |fee_type|
  wait_for_ajax(10)
  within fee_type_to_id(fee_type) do
    expect(page).to_not have_content('Date attended (from)')
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
  if @claim.is_a? Claim::AdvocateClaim
    choose 'I attended the main hearing (1st day of trial)'
  end

  click_on 'Certify and submit claim'
end

Given(/^I add dates attended for the first miscellaneous fee$/) do
  within '#misc-fees' do
    click_on 'Add date(s)'
  end
end

Given(/^I fill in an invalid date from$/) do
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
  choose 'QC'

  within '.defendants' do
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

  end

  unless details == ' but add no fees or expenses' # preceeding space is required for match
    within '#basic-fees' do
      fill_in 'claim_basic_fees_attributes_0_quantity', with: 1
      fill_in 'claim_basic_fees_attributes_0_rate', with: 50
      fill_in 'claim_basic_fees_attributes_1_quantity', with: 1
      fill_in 'claim_basic_fees_attributes_1_rate', with: 50
    end

    within '#expenses' do
      select 'Travel', from: 'claim_expenses_attributes_0_expense_type_id'
      fill_in 'claim_expenses_attributes_0_location', with: 'London'
      fill_in 'claim_expenses_attributes_0_quantity', with: 1.1
      fill_in 'claim_expenses_attributes_0_rate', with: 40
    end
  end

  within '.evidence-checklist' do
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
  expect(Claim::BaseClaim.where(state: 'draft').count).to eq 1
end

Then(/^I should be redirected to the claim confirmation page$/) do
  claim = Claim::BaseClaim.first
  expect(page.current_path).to eq(confirmation_external_users_claim_path(claim))
end

Then(/^I should be redirected to the claim summary page$/) do
  claim = Claim::BaseClaim.first
  expect(page.current_path).to eq(summary_external_users_claim_path(claim))
end

Then(/^I should be redirected to the claim certification page$/) do
  claim = Claim::BaseClaim.first
  expect(page.current_path).to eq(new_external_users_claim_certification_path(claim))
end

Then(/^I should be redirected back to the claim form with error$/) do
  expect(page).to have_content('Claim for advocate graduated fees')
  expect(page).to have_content(/This claim has \d+ errors?/)
  expect(page).to have_content("Choose an advocate")
end


Then(/^I should see the claim totals$/) do
  within('.confirmation-section') do
    expect(page).to have_content("Fees total: £100.00")
    expect(page).to have_content("Expenses total: £40.00")
    expect(page).to have_content("Claim total: £164.50")
  end
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
  claim = Claim::BaseClaim.first
  expect(page.current_path).to eq(edit_advocates_claim_path(claim))
end

Then(/^I should be on the claim confirmation page$/) do
  claim = @claim || Claim::BaseClaim.first
  expect(page.current_path).to eq(confirmation_external_users_claim_path(claim))
end

Given(/^a claim exists$/) do
  create(:claim, external_user_id: ExternalUser.first.id)
end

Given(/^a claim exists with state "(.*?)"$/) do |claim_state|
  @claim = case claim_state
    when "draft"
      create(:claim, external_user_id: ExternalUser.first.id)
    else
      create(:claim, external_user_id: ExternalUser.first.id)
  end
end

Then(/^the claim should be in state "(.*?)"$/) do |claim_state|
  @claim.reload
  expect(@claim.state).to eq(claim_state)
end

When(/^I am on the claim edit page$/) do
  claim = Claim::BaseClaim.first
  visit edit_advocates_claim_path(claim)
end

Then(/^I can view a select of all advocates in my provider$/) do
  expect(page).to have_selector('select#claim_external_user_id')
  expect(page).to have_content('Doe, John: AC135')
  expect(page).to have_content('Blow, Joe: XY455')
end

When(/^I select Advocate name "(.*?)"$/) do |advocate_name|
  select(advocate_name, from: 'claim_external_user_id')
end

Then(/^I should be redirected to the claims list page$/) do
  expect(page.current_path).to eq(external_users_claims_path)
end

Then(/^I should see my claim under drafts$/) do
  claim = Claim::BaseClaim.first
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
  claim = Claim::BaseClaim.first
  expect(claim.state).to eq(state)
end

Then(/^I should see errors$/) do
  expect(page).to have_content(/This claim has \d+ errors?/)
end

Then(/^I should not see errors$/) do
  expect(page).not_to have_content(/This claim has \d+ errors?/)
end

Then(/^no claim should be submitted$/) do
  expect(Claim::BaseClaim.where(state: 'submitted').count).to be_zero
end

When(/^I change the case number$/) do
  fill_in 'claim_case_number', with: 'A87654321'
end

Then(/^the case number should reflect the change$/) do
  claim = Claim::BaseClaim.first
  expect(claim.case_number).to eq('A87654321')
end

When(/^I add a fixed fee$/) do
    within '#fixed-fees' do
      fill_in 'claim_fixed_fees_attributes_0_quantity', with: 1
      fill_in 'claim_fixed_fees_attributes_0_rate', with: 100.00
      select 'Fixed Fee example', from: 'claim_fixed_fees_attributes_0_fee_type_id'
    end
end

Then(/^I should see the claim totals accounting for only the fixed fee$/) do
  expect(page).to have_content("Fees total: £100.00")
end

When(/^I add a miscellaneous fee$/) do
    within '#misc-fees' do
      fill_in 'claim_misc_fees_attributes_0_quantity', with: 1
      fill_in 'claim_misc_fees_attributes_0_rate', with: 200.00
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
  expect(Claim::BaseClaim.last.calculate_fees_total(:basic).to_f).to eql(0.0)
end

Then(/^There should be a Miscellaneous Fee Saved$/) do
  expect(Claim::BaseClaim.last.misc_fees.size).to eql(1)
end


Then(/^There should not be any Fixed Fees saved$/) do
  expect(Claim::BaseClaim.last.fixed_fees.size).to eql(0)
end

Then(/^I should( not)? be able to view "(.*?)"$/i) do |have, content|
  to_or_not_to = have.nil? ? 'to' : have.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'
  expect(page).method(to_or_not_to).call have_content(content)
end

Given(/^I fill in an Initial Fee$/) do
  within '#basic-fees' do
    fill_in 'claim_basic_fees_attributes_0_quantity', with: 2
    fill_in 'claim_basic_fees_attributes_0_rate', with: 0.75
  end
end

Given(/^I fill in a Miscellaneous Fee$/) do
  within '#misc-fees' do
    select 'Miscellaneous Fee example', from: 'claim_misc_fees_attributes_0_fee_type_id'
    fill_in 'claim_misc_fees_attributes_0_quantity', with: 2
    fill_in 'claim_misc_fees_attributes_0_rate', with: 1.50
  end
end

Given(/^I fill in a Fixed Fee$/) do
  within '#fixed-fees' do
    select 'Fixed Fee example', from: 'claim_fixed_fees_attributes_0_fee_type_id'
    fill_in 'claim_fixed_fees_attributes_0_quantity', with: 2
    fill_in 'claim_fixed_fees_attributes_0_rate', with: 1.50
  end
end

Given(/^I fill in a Fixed Fee using select2$/) do
  within '#fixed-fees' do
    # select2 'Fixed Fee example', from: 'claim_fixed_fees_attributes_0_fee_type_id' # does not work
    fill_in 'claim_fixed_fees_attributes_0_quantity', with: 2
    fill_in 'claim_fixed_fees_attributes_0_rate', with: 1.50
  end
end

Given(/^a non\-fixed\-fee claim exists with basic and miscellaneous fees$/) do
  claim = create(:draft_claim, :without_misc_fee, case_type_id: CaseType.by_type('Trial').id, external_user_id: ExternalUser.first.id)
  claim.misc_fees.map(&:destroy)    # remove the misc fee created in the claim factory
  create(:basic_fee, claim: claim, quantity: 3, amount: 7.0)
  create(:misc_fee, claim: claim, quantity: 2, amount: 5.0)
end

Given(/^I am on the new claim page with Daily Attendance Fees in place$/) do
  create(:basic_fee_type, description: 'Basic Fee', code: 'BAF')
  create(:basic_fee_type, description: 'Daily attendance fee (3 to 40)',  code: 'DAF')
  create(:basic_fee_type, description: 'Daily attendance fee (41 to 50)', code: 'DAH')
  create(:basic_fee_type, description: 'Daily attendance fee (51+)',      code: 'DAJ')
  visit new_advocates_claim_path
end

When(/^I fill in actual (re)?trial length with (\d+)$/) do |trial_prefix,trial_Length|
  id = trial_prefix.blank? ? 'claim_actual_trial_length' : 'claim_retrial_actual_length'
  fill_in id, with: trial_Length.to_i
end

Then(/^The daily attendance fields should have quantities (\d+), (\d+), (\d+)$/) do |daf_quantity, dah_quantity, daj_quantity|
  daf_quantity = '' if daf_quantity.nil? || daf_quantity.to_i == 0
  dah_quantity = '' if dah_quantity.nil? || dah_quantity.to_i == 0
  daj_quantity = '' if daj_quantity.nil? || daj_quantity.to_i == 0
  expect(page).to have_field("claim_basic_fees_attributes_1_quantity", with: "#{daf_quantity}")
  expect(page).to have_field("claim_basic_fees_attributes_2_quantity", with: "#{dah_quantity}")
  expect(page).to have_field("claim_basic_fees_attributes_3_quantity", with: "#{daj_quantity}")
end

Given(/^There are PPE and NPW fees in place$/) do
  create(:basic_fee_type, :npw)
  create(:basic_fee_type, :ppe)
end

Then(/^I fill in quantity (\d+) and amount (\d+) for "(.*?)"$/) do |quantity, amount, fee_code|
  # use the fee type code to determine the index in the table of fees
  fee_type_codes = Fee::BasicFeeType.all.map(&:code)
  id_no = fee_type_codes.index(fee_code)

  quantity_input = "claim_basic_fees_attributes_#{id_no}_quantity"
  amount_input = "claim_basic_fees_attributes_#{id_no}_amount"
  fill_in quantity_input, with: quantity.to_i
  fill_in amount_input, with: amount.to_f
end

Then(/^The total claimed should equal (\d+)$/) do |total_claimed|
  expect(Claim::BaseClaim.last.total).to eq total_claimed.to_f
end

# local helpers
# -----------------
def fee_type_to_id(fee_type)
  div_id = fee_type.downcase == "fixed" ? 'fixed-fees' : 'misc-fees'
  "##{div_id}"
end
