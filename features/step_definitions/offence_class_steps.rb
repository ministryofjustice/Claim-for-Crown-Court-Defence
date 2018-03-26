Then(/^the offence_class drop_down is set to '(.*?)'$/) do |text|
  expect(page).to have_xpath("//option[text()='#{text}']")
end

Then(/^the offence_class drop_down has (.*?) options$/) do |count|
  expect(page).to have_xpath('//select[@id="offence_class_description"]/option', count: count)
end
