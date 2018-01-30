When(/^I fill in the '(.*?)' form$/) do |payload|
  case payload
  when 'feedback'
    fill_in 'feedback[comment]', with: 'This is great!'
    choose('Very satisfied')
    click_on 'Send'
  when 'bug report'
    fill_in 'feedback[event]', with: 'Filling in a new claim form'
    fill_in 'feedback[outcome]', with: 'Something went wrong'
    click_on 'Send'
  end
end

When(/^I fill in the '(.*?)' form with email of '(.*?)'$/) do |payload, email|
  case payload
    when 'feedback'
      fill_in 'feedback[comment]', with: 'This is great!'
      choose('Very satisfied')
      fill_in 'feedback[email]', with: email
      click_on 'Send'
    when 'bug report'
      fill_in 'feedback[event]', with: 'Filling in a new claim form'
      fill_in 'feedback[outcome]', with: 'Something went wrong'
      click_on 'Send'
  end
end

When(/^I have not signed in$/) do
  visit new_user_session_path
end

Then(/^I expect ZendeskSender to receive a description (with|without) an email$/) do |visibility|
  if (visibility == 'with')
    regex = /email:\s\w/
  else
    regex = /email:\s\"/
  end
  expect(@called_zendesk.with { |req| regex.match(req.body) }).to have_been_made.once
end

Then(/^I see confirmation that my '(.*?)' was received$/) do |payload|
  case payload
  when 'feedback'
    expect(page).to have_content "Feedback submitted"
  when 'bug report'
    expect(page).to have_content "Feedback submitted"
  end
end

Then(/^I should be informed that I have signed out$/) do
  expect(page).to have_content('You have signed out')
end

Then(/^I should be redirected to the feedback page$/) do
  expect(current_path).to eq(new_feedback_path)
end

Then(/^I should be on the sign in page$/) do
  expect(current_path).to eq(new_user_session_path)
end
