When(/^I click '(.*?)'$/) do |link_or_button|
  click_on link_or_button
end

When(/^I fill in the '(.*?)' form$/) do |payload|
  case payload
  when 'feedback'
    fill_in 'feedback[comment]', with: 'This is great!'
    choose('Very satisfied')
    click_on 'Send'
  when 'bug report'
    fill_in 'bug_report[event]', with: 'Filling in a new claim form'
    fill_in 'bug_report[outcome]', with: 'Something went wrong'
    click_on 'Send'
  end
end

Then(/^I see confirmation that my '(.*?)' was received$/) do |payload|
  case payload
  when 'feedback'
    expect(page).to have_content "Feedback submitted"
  when 'bug report'
    expect(page).to have_content "Feedback submitted"
  end
end