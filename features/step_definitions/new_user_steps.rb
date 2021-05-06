Then('I am on the new users page') do
  expect(@new_user_page).to be_displayed
end

And('I fill in {string} with {string}') do |label, text|
  fill_in label, with: text
end

And('I click govuk checkbox {string}') do |label|
  find('.govuk-checkboxes__item label', text: label).click
end

# e.g.
#  And I choose govuk radio "Yes" for "Get email notifications of caseworker messages on claims you created?"
#
And('I choose govuk radio {string} for {string}') do |label, legend|
  within('.govuk-fieldset', text: legend) do
    find('.govuk-radios__item label', text: label).click
  end
end
