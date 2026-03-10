When(/^I have not signed in$/) do
  visit new_user_session_path
end

Then('I see confirmation that my bug report was received') do
  expect(page).to have_govuk_notification_banner(text: 'Bug Report submitted')
end

Then('I see a warning that my bug report was not submitted successfully') do
  expect(page).to have_govuk_notification_banner(text: /Unable to submit bug report/)
end

Then(/^I should be informed that I have signed out$/) do
  expect(page).to have_content('You have signed out')
end

Then(/^I should be on the bug report page$/) do
  expect(current_path).to eq(feedback_index_path)
end

Then(/^I should be on the sign in page$/) do
  expect(current_path).to eq(new_user_session_path)
end
