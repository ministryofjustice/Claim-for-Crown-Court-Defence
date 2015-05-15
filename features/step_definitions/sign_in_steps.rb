def make_accounts(role, number = 1)
  @password = 'password'
  case role
    when 'advocate'
      @advocates = create_list(:advocate, number)
    when 'advocate admin'
      create(:advocate, :admin)
    when 'case worker'
      create_list(:case_worker, number)
    when 'case worker admin'
      create(:case_worker, :admin)
  end
end


Given(/an "(.*?)" user account exists$/) do |role|
  make_accounts(role)
end

Given(/^(\d+) "(.*?)" user accounts exist who work for (the same|different) chambers?$/) do |number, role, chambers|
  make_accounts(role, number.to_i)
  if chambers == 'the same'
    the_chamber = create(:chamber)
    @advocates.each { |a| a.chamber = the_chamber; a.save }
  else
    @advocates.each { |a| a.chamber = create(:chamber); a.save }
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
