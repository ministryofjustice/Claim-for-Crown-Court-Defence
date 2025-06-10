And(/^Zendesk Feedback is '(.*?)'$/) do |state|
  case state
  when 'Enabled'
    allow(Settings).to receive(:zendesk_feedback_enabled?).and_return(true)
  when 'Disabled'
    allow(Settings).to receive(:zendesk_feedback_enabled?).and_return(false)
  end
end

When(/^I have not signed in$/) do
  visit new_user_session_path
end

Then(/^I see confirmation that my '(.*?)' was received$/) do |feedback_type|
  case feedback_type
  when 'feedback'
    expect(page).to have_govuk_notification_banner(text: :notice, text: 'Feedback submitted')
  when 'bug report'
    expect(page).to have_govuk_notification_banner(text: :notice, text: 'Bug Report submitted')
  end
end

Then('I see a warning that my feedback was not submitted successfully') do
  expect(page).to have_govuk_notification_banner(key: :error, text: /Unable to submit feedback/)
end

Then('I see a warning that my bug report was not submitted successfully') do
  expect(page).to have_govuk_notification_banner(text: :error, text: /Unable to submit bug report/)
end

Then(/^I should be informed that I have signed out$/) do
  expect(page).to have_content('You have signed out')
end

Then(/^I should be on the feedback page$/) do
  expect(current_path).to eq(feedback_index_path)
end

Then(/^I should be on the bug report page$/) do
  expect(current_path).to eq(feedback_index_path)
end

Then(/^I should be on the sign in page$/) do
  expect(current_path).to eq(new_user_session_path)
end
