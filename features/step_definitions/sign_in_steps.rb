Given(/^an? "(.*?)" user account exists$/) do |role|
  @password = 'password'
  create(role.gsub(/\s/, '_').to_sym, password: @password, password_confirmation: @password)
end

When(/^I vist the user sign in page$/) do
  visit new_user_session_path
end

When(/^I enter my email, password and click log in$/) do
  fill_in 'Email', with: User.first.email
  fill_in 'Password', with: @password
  click_on 'Log in'
end

Then(/^I should be redirected to the "(.*?)" root url$/) do |namespace|
  case namespace.gsub(/\s/, '_')
  when 'advocates'
    expect(current_url).to eq(advocates_root_url)
  when 'case_workers'
    expect(current_url).to eq(case_workers_root_url)
  when 'admin'
    expect(current_url).to eq(admin_root_url)
  end
end
