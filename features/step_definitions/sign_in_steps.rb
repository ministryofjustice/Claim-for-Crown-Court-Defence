def make_accounts(role, number = 1)
  @password = 'password'
  case role
    when 'advocate'
      @advocates = create_list(:external_user, number)
    when 'advocate admin'
      @advocate_admins = create_list(:external_user, number, :admin)
    when 'litigator'
      @advocates = create_list(:external_user, :litigator, number)
    when 'litigator admin'
      @advocates = create_list(:external_user, :litigator_and_admin, number)
    when 'case worker'
      @case_workers = create_list(:case_worker, number)
    when 'case worker admin'
      create(:case_worker, :admin)
    when 'super admin'
      @super_admin = create(:super_admin)
  end
end

Given(/^The caseworker is marked as deleted$/) do
  @case_worker.soft_delete
end

Given(/an? "(.*?)" user account exists$/) do |role|
  accounts = make_accounts(role)
  instance_variable_set("@#{role.gsub(' ', '_')}", accounts.first)
end

Given(/^I am a signed in advocate$/) do
  @advocate = create(:external_user, :advocate)
  visit new_user_session_path
  switch_to_chrome_window
  sign_in(@advocate.user, 'password')
end

Given(/^I am a signed in advocate admin$/) do
  @advocate = create(:external_user, :advocate_and_admin)
  visit new_user_session_path
  switch_to_chrome_window
  sign_in(@advocate.user, 'password')
end

Given(/^I am a signed in litigator$/) do
  @litigator = create(:external_user, :litigator)
  visit new_user_session_path
  switch_to_chrome_window
  sign_in(@litigator.user, 'password')
end

Given(/^I am a signed in litigator admin$/) do
  @litigator = create(:external_user, :litigator_and_admin)
  visit new_user_session_path
  switch_to_chrome_window
  sign_in(@litigator.user, 'password')
end

Given(/^I am a signed in admin for an AGFS and LGFS firm$/) do
  @admin = create(:external_user, :agfs_lgfs_admin)
  visit new_user_session_path
  switch_to_chrome_window
  sign_in(@admin.user, 'password')
end

Given(/^I am a signed in case worker$/) do
  @case_worker = create(:case_worker)
  visit new_user_session_path
  switch_to_chrome_window
  sign_in(@case_worker.user, 'password')
end

Given(/^I am signed in as the case worker$/) do
  sign_in(@case_worker, @password)
end

When(/^I sign in as the advocate$/) do
  sleep 5
  sign_in(@advocate.user, @password)
end

When(/^I sign in as the case worker$/) do
  sign_in(@case_worker.user, @password)
end

When(/^I attempt to sign in again as the deleted caseworker$/) do
  sign_in(@case_worker.user, 'password')
end

Given(/^I am a signed in case worker admin$/) do
  @case_worker = create(:case_worker, :admin)
  sign_in(@case_worker.user, 'password')
end

Given(/^I am a signed in super admin$/) do
  make_accounts('super admin')
  visit new_user_session_path
  sign_in(@super_admin.user, 'password')
end

Then(/^I should see an Manage advocates link and it should work$/) do
  find('#primary-nav').click_link('Manage users')
  expect(find('#page-h1')).to have_content('Manage users')
end

Given(/^I sign out$/) do
  using_wait_time 20 do
    click_link "Sign out"
    expect(page).to have_content('You have signed out')
    expect(current_path).to eql new_feedback_path
  end
end

When(/^I should be on the Allocation page$/) do
  expect(find('#page-h1')).to have_content('Allocation')
end

Then(/^I should get a page telling me my account has been deleted$/) do
  expect(page).to have_content('This account has been deleted.')
end
