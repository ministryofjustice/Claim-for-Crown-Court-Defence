
def make_accounts(role, number = 1)
  @password = 'password'
  case role
    when 'advocate'
      @advocates = create_list(:advocate, number)
    when 'advocate admin'
      @advocate_admins = create_list(:advocate, number, :admin)
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
  @advocate = create(:advocate)
  visit new_user_session_path
  sign_in(@advocate.user, 'password')
end

Given(/^I am a signed in advocate admin$/) do
  @advocate = create(:advocate, :admin)
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
  find('#primary-nav').click_link('Manage advocates')
  expect(find('h1.page-title')).to have_content('Manage advocates')
end
