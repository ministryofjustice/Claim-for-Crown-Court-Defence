
When(/^I view status details for a claim$/) do
	within(".claims_table") do
	  first('a.js-test-case-number-link').click
	end
end

When(/^I select status "(.*?)" from select$/) do |status|
	select "#{status}", :from => "claim_state_for_form"
end

# When(/^I enter amount assessed value of "(.*?)"$/) do |amount|
When(/^I enter fees assessed of "(.*?)" and expenses assessed of "(.*?)"$/) do |fees, expenses|
  fill_in 'claim_assessment_attributes_fees', with: fees unless fees.empty?
  fill_in 'claim_assessment_attributes_expenses', with: expenses unless expenses.empty?
	# find('div#amountAssessed').fill_in "Amount assessed", with: amount unless amount.empty?
end

When(/^I press update button$/) do
  click_button "Update"
end

Given(/^I have (\d+) allocated claims whos status is "(.*?)" with fees assessed of "(.*?)" and expenses assessed of "(.*?)"$/) do |number, status, fees, expenses|
  claims = create_list(:allocated_claim, number.to_i, advocate: @advocate)
  claims.each do |claim|
    claim.assessment.update!(fees: fees) unless fees.empty?
    claim.assessment.update!(expenses: expenses) unless expenses.empty?

		case status
			when "Part authorised"
				claim.authorise_part!
			when "Rejected"
				claim.reject!
			when "Rejected"
				claim.reject!
			else
				raise "ERROR: Invalid status specified for advocate view scenario"
		end
  end
end

When(/^I view status details of my first claim$/) do
	@claim = Claim.where(advocate: @advocate).first
  visit advocates_claim_path(@claim)
end

Then(/^I should see "(.*?)" total assessed value of "(.*?)"$/) do |disabled, total|
	total = "£0.00" if total.empty?
	disabled = disabled == "disabled" ? true : false
  expect(find_by_id('determination-total').text).to eql total
end

Then(/^I should see "(.*?)" status select with "(.*?)" selected$/) do |disabled, status|
	disabled = disabled == "disabled" ? true : false
	expect(find_field('claim_state_for_form', disabled: disabled).find('option[selected]').text).to eql(status)
end

When(/^the claim state should be allocated$/) do
  expect(Claim.all.pluck(:state).uniq).to eq(['allocated'])
end

Then(/^I should see error "(.*?)"$/) do |error_message|
  expect(page).to have_content(error_message)
end

Then(/^I should not see "(.*?)"$/) do |error_message|
  expect(page).not_to have_content(error_message)
end

Then(/^I should not see status select$/) do
  expect(page).not_to have_content('Select new state for this claim')
end

Then(/^I should see the current status set to "(.*)"$/) do |state|
  expect(page).to have_content("Current status: #{state}")
end

Then(/^I should be able to update the status from "(.*)"$/) do |state|
  expect(page).to have_content("Update status (current status: '#{state}')")
end

Then(/^I should see an option select for claim status$/) do
  expect(page).to have_selector('#claim_state_for_form')
end

