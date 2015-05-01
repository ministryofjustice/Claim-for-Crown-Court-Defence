Given(/^an? "(.*?)" user account exists$/) do |role|
  @password = 'password'
  case role
    when 'advocate'
      create(:advocate)
    when 'advocate admin'
      create(:advocate, :admin)
    when 'case worker'
      create(:case_worker)
    when 'case worker admin'
      create(:case_worker, :admin)
  end
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
  when 'advocates admin'
    expect(current_url).to eq(advocates_admin_root_url)
  when 'case workers'
    expect(current_url).to eq(case_workers_root_url)
  when 'case workers admin'
    expect(current_url).to eq(case_workers_admin_root_url)
  end
end
