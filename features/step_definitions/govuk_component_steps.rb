# frozen_string_literal: true

When('I click govuk checkbox {string}') do |label|
  find('.govuk-checkboxes__item label', text: label).click
end

When('I uncheck the govuk checkbox {string}') do |label|
  find('.govuk-checkboxes__item label', text: label).click
end

When('I choose govuk radio {string} for {string}') do |label, legend|
  find('.govuk-fieldset__legend', text: legend)
    .find(:xpath, '..')
    .find('.govuk-radios__item label', text: label).click
end

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

Then('the following govuk error details should exist:') do |table|
  table.hashes.each do |row|
    type = row['field_type']
    locator = row['field_locator']
    summary_error_text = row['summary_error_text']
    field_error_text = row['field_error_text']
    id = row['linked_id']

    expect(page).to have_govuk_error_summary(summary_error_text, href: "##{id}")
    expect(page).to send("have_govuk_error_#{type}", locator, text: field_error_text, id: id)
  end
end

