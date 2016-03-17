Given(/^Test mailer is reset$/) do
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.deliveries = []
end

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
    choose('case_worker[location_id]')
    check('case_worker_roles_case_worker')
  end
end

Then(/^I see confirmation that a new "(.*?)" user has been created$/) do |persona|
  expect(page).to have_content "#{persona} successfully created"
end

Then(/^a welcome email is sent to the new user$/) do
  expect(ActionMailer::Base.deliveries.length).to eq 1
  expect(ActionMailer::Base.deliveries.last.to).to eq ["harold.hughes@example.com"]
  expect(ActionMailer::Base.deliveries.last.subject).to eq "Welcome to Claim for crown court defence"
  expect(ActionMailer::Base.deliveries.last.to_s).to include("Dear Harold Hughes,","You have been registered", "Reset your password", "This link will expire in") #multipart email so need to stringify it
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

Given(/^I am an advocate that has signed in before/) do
  @advocate = create(:external_user, :advocate)
  @advocate.user.first_name = 'Ned'
  @advocate.user.last_name = 'Passreset'
  @advocate.user.email = 'ned.passreset@example.com'
  @advocate.user.sign_in_count = 21
  @advocate.save
end

Given(/^I am on the Forgot your password\? page$/) do
  visit new_user_password_path
end

When(/^I fill in my email details$/) do
  fill_in 'user_email', with: @advocate.email
end

Then(/^a password reset email is sent to the user$/) do
  expect(ActionMailer::Base.deliveries.length).to eq 1
  expect(ActionMailer::Base.deliveries.last.to).to eq ["ned.passreset@example.com"]
  expect(ActionMailer::Base.deliveries.last.subject).to eq "Claim for crown court defence - change your password"
  expect(ActionMailer::Base.deliveries.last.to_s).to include("Dear Ned Passreset,","Someone has requested a link to change your password", "Change your password", "This link will expire in") #multipart email so need to stringify it
end
