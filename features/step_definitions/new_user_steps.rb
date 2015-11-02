Given(/^I am on the new "(.*?)" page$/) do |persona|
  personas = persona.pluralize
  visit "/#{personas}/admin/#{personas}/new"
end

When(/^I fill in the "(.*?)" details$/) do |persona|
  fill_in "#{persona}_user_attributes_first_name", with: 'Harold'
  fill_in "#{persona}_user_attributes_last_name", with: 'Hughes'
  fill_in "#{persona}_user_attributes_email", with: 'harold.hughes@example.com'
  case persona
  when 'advocate'
    choose(('advocate[apply_vat]').first)
    fill_in 'advocate_supplier_number', with: '31425'
    choose(("#{persona}[role]").first)
  when 'case_worker'
    check('case_worker[days_worked_0]')
    choose('case_worker_approval_level_high')
    choose('case_worker[location_id]')
    choose('case_worker_role_case_worker')
  end
end

When(/^click save$/) do
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  click_on 'Save'
end

Then(/^I see confirmation that a new "(.*?)" user has been created$/) do |persona|
  expect(page).to have_content "#{persona} successfully created"
end

Then(/^an email is sent to the new user$/) do
  expect(ActionMailer::Base.deliveries.length).to eq 1
  expect(ActionMailer::Base.deliveries.first.to).to eq ["harold.hughes@example.com"]
  expect(ActionMailer::Base.deliveries.first.subject).to eq "Advocate Defense Payments - Change your password"
end
