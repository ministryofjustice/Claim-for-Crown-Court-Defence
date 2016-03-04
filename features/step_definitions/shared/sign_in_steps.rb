
def make_accounts(role, number = 1)
  @password = 'password'
  case role
    when 'advocate'
      @advocates = create_list(:external_user, number)
    when 'advocate admin'
      @advocate_admins = create_list(:external_user, number, :admin)
    when 'case worker'
      @case_workers = create_list(:case_worker, number)
    when 'case worker admin'
      create(:case_worker, :admin)
    when 'super admin'
      @super_admin = create(:super_admin)
  end
end

Given(/an? "(.*?)" user account exists$/) do |role|
  make_accounts(role)
end

Given(/^I am a signed in advocate$/) do
  @advocate = create(:external_user)
  visit new_user_session_path
  sign_in(@advocate.user, 'password')
end

Given(/^I am a signed in advocate admin$/) do
  @advocate = create(:external_user, :advocate_and_admin)
  visit new_user_session_path
  sign_in(@advocate.user, 'password')
end

Given(/^I am a signed in case worker$/) do
  @case_worker = create(:case_worker)
  visit new_user_session_path
  sign_in(@case_worker.user, 'password')
end

Given(/^I am a signed in case worker admin$/) do
  @case_worker = create(:case_worker, :admin)
  visit new_user_session_path
  sign_in(@case_worker.user, 'password')
end

Given(/^I am a signed in super admin$/) do
  make_accounts('super admin')
  visit new_user_session_path
  sign_in(@super_admin.user, 'password')
end

Then(/^I should see an Manage advocates link and it should work$/) do
  find('#primary-nav').click_link('Manage users')
  expect(find('header.main-header')).to have_content('Manage users')
end

Given(/^I sign out$/) do
  click_link 'Sign out' rescue nil
end
