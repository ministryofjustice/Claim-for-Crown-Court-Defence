
When(/^I view status details for a claim$/) do
	first('div.claim-controls').click_link("Detail")
end

When(/^I select status radio button label "(.*?)"$/) do |radio_label|
	find('#claim-status').choose radio_label
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

Then(/^I should see enabled status radio button "(.*?)" chosen$/) do |name|
	expect(find('#claim-status').has_checked_field?(name, disabled: false)).to eql(true)
end

Then(/^I should see remark "(.*?)"$/) do |remark|
  expect(find_field('Remarks').value).to eq(remark)
end
