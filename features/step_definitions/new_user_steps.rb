Given(/^I am on the new "(.*?)" page$/) do |persona|
  personas = persona.pluralize
  visit "/#{personas}/admin/#{personas}/new"
end

When(/^I fill in the "(.*?)" details$/) do |persona|
  fill_in "#{persona}_user_attributes_first_name", with: 'Harold'
  fill_in "#{persona}_user_attributes_last_name", with: 'Hughes'
  fill_in "#{persona}_user_attributes_email", with: 'harold.hughes@example.com'
  fill_in "#{persona}_user_attributes_email_confirmation", with: 'harold.hughes@example.com'
  case persona
  when 'external_user'
    if @advocate.provider.chamber?
      choose('external_user_vat_registered_true')
      fill_in 'external_user_supplier_number', with: '31425'
    end
    check('external_user_roles_admin')
  when 'case_worker'
    check('case_worker[days_worked_0]')
    choose('case_worker[location_id]')
    check('case_worker_roles_case_worker')
  end
end

When(/^I fill in the "(.*?)" details but email and email_confirmation do not match$/) do |persona|
  fill_in "#{persona}_user_attributes_first_name", with: 'Harold'
  fill_in "#{persona}_user_attributes_last_name", with: 'Hughes'
  fill_in "#{persona}_user_attributes_email", with: 'harold.hughes@example.com'
  fill_in "#{persona}_user_attributes_email_confirmation", with: 'another_email@example.com'
  case persona
  when 'external_user'
    choose('external_user_vat_registered_true')
    fill_in 'external_user_supplier_number', with: '31425'
    check('external_user_roles_admin')
  when 'case_worker'
    check('case_worker[days_worked_0]')
    choose('case_worker[location_id]')
    check('case_worker_roles_case_worker')
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
  expect(ActionMailer::Base.deliveries.first.subject).to eq "Claim for crown court defence - change your password"
end

Then(/^the email body should be as expected$/) do
  expect(ActionMailer::Base.deliveries.first.body).to include("Dear Harold Hughes,")
end

Then(/^I see an error message$/) do
  expect(page).to have_content "Email confirmation and email must match"
end

Then(/^I should (not )?see the supplier number or VAT registration fields$/) do |negate|
  if negate.present?
    expect(page).to_not have_content(/supplier number/i)
    expect(page).to_not have_content(/vat registered/i)
  else
    expect(page).to have_content(/supplier number/i)
    expect(page).to have_content(/vat registered/i)
  end
end

When(/^I check "(.*?)"$/) do |role|
  check role
end
