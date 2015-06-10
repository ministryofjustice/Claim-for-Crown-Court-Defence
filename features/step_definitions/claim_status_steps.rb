
When(/^I view status details for a claim$/) do
	first('div.claim-controls').click_link("Detail")
end

When(/^I select status "(.*?)" from select$/) do |status|
	select "#{status}", :from => "claim_state_for_form"
end

When(/^I enter amount assessed value of "(.*?)"$/) do |amount|
	find('div#amountAssessed').fill_in "Amount assessed", with: amount unless amount.empty?
end

When(/^I enter remark "(.*?)"$/) do |remark|
	fill_in	"Remarks", with: remark
end

When(/^I press update button$/) do
  click_button "Update"
end

Given(/^I have (\d+) allocated claims whos status is "(.*?)" with amount assessed of "(.*?)" and remark of "(.*?)"$/) do |number, status, amount, remark|
  claims = create_list(:allocated_claim, number.to_i, advocate: @advocate)
  claims.each do |claim|
		claim.amount_assessed = amount unless amount.empty?
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

Then(/^I should see "(.*?)" amount assessed value of "(.*?)"$/) do |disabled, amount|
	amount = "0.00" if amount.empty?
	disabled = disabled == "disabled" ? true : false
	expect(find_field('Amount assessed', disabled: disabled).value).to eql(amount.to_s)
end

Then(/^I should see "(.*?)" remark "(.*?)"$/) do |disabled,remark|
	disabled = disabled == "disabled" ? true : false
  expect(find_field('Remarks', disabled: disabled).value).to eq(remark)
end

Then(/^I should see "(.*?)" status select with "(.*?)" selected$/) do |disabled, status|
	disabled = disabled == "disabled" ? true : false
	expect(find_field('claim_state_for_form', disabled: disabled).find('option[selected]').text).to eql(status)
end

Then(/^I should see an image tag with source "(.*?)" against that claim$/) do |image_source|
	expect(find('.status-indicator')['src'].include?(image_source)).to eql(true)
end
