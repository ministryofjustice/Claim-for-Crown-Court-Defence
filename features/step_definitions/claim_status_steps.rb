
When(/^I view status details for a claim$/) do
	within("#claims-list") do
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

When(/^I enter remark "(.*?)"$/) do |remark|
	fill_in	"Remarks", with: remark
end

When(/^I press update button$/) do
  click_button "Update"
end

Given(/^I have (\d+) allocated claims whos status is "(.*?)" with fees assessed of "(.*?)" and expenses assessed of "(.*?)" and remark of "(.*?)"$/) do |number, status, fees, expenses, remark|
  claims = create_list(:allocated_claim, number.to_i, advocate: @advocate)
  claims.each do |claim|
    claim.assessment.update!(fees: fees) unless fees.empty?
    claim.assessment.update!(expenses: expenses) unless expenses.empty?
		claim.additional_information = remark

		case status
			when "Part paid"
				claim.pay_part!
			when "Rejected"
				claim.reject!
			when "Rejected"
				claim.reject!
			when "Awaiting info from court"
				claim.await_info_from_court!
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
  expect(find_by_id('assessed-total').text).to eql total
end

Then(/^I should see "(.*?)" remark "(.*?)"$/) do |disabled,remark|
	disabled = disabled == "disabled" ? true : false
  expect(find_field('Remarks', disabled: disabled).value).to eq(remark)
end

Then(/^I should see "(.*?)" status select with "(.*?)" selected$/) do |disabled, status|
	disabled = disabled == "disabled" ? true : false
	expect(find_field('claim_state_for_form', disabled: disabled).find('option[selected]').text).to eql(status)
end

When(/^the claim state should be allocated$/) do
  expect(Claim.all.pluck(:state).uniq).to eq(['allocated'])
end
