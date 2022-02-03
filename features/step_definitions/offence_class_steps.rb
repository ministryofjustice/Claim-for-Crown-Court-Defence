Then(/^the offence class list is set to '(.*?)'$/) do |text|
  expect(page).to have_xpath("//option[text()='#{text}']")
end

Then(/^the offence class list has (.*?) options$/) do |count|
  expect(page).to have_xpath('//select[@id="claim-offence-class-field"]/option', count: count)
end
