# frozen_string_literal: true

Then('I should see govuk error summary with {string}') do |text|
  expect(page).to have_govuk_error_summary(text)
end

Then('I should see govuk error summary with {string} linking to {string}') do |text, href|
  expect(page).to have_govuk_error_summary(text, href: href)
end

Then('I should see govuk error field for {string} with error {string} and id {string}') do |locator, text, id|
  expect(page).to have_govuk_error_field(locator, text: text, id: id)
end

Then('I should see govuk error fieldset for {string} with error {string} and id {string}') do |locator, text, id|
  expect(page).to have_govuk_error_fieldset(locator, text: text, id: id)
end

Then('the following error details should exist:') do |table|
  table.hashes.each do |row|
    type, locator, text, id = row['field_type'], row['field_locator'], row['error_text'], row['linked_id']

    expect(page).to have_govuk_error_summary(text, href: "##{id}")
    expect(page).to send("have_govuk_error_#{type}", locator, text: text, id: id)
  end
end

