
Given(/^(\d+) "(.*?)" user accounts? exists? who works? for (the same|different) chambers?$/) do |number, role, chambers|
  make_accounts(role, number.to_i)
  if chambers == 'the same'
    the_chamber = create(:chamber)
    @advocates.each { |a| a.chamber = the_chamber; a.save } if @advocates
    @advocate_admins.each { |a| a.chamber = the_chamber; a.save } if @advocate_admins
  else
    @advocates.each { |a| a.chamber = create(:chamber); a.save } if @advocates
    @advocate_admins.each { |a| a.chamber = create(:chamber); a.save } if @advocate_admins
  end
end

When(/^I visit the user sign in page$/) do
  visit new_user_session_path
end

Given(/^(?:the|that)(?: (\d+)\w+)? advocate admin signs in$/) do |cardinality|
  card = cardinality.nil? ? 1 : cardinality
  @user = @advocate_admins[card.to_i-1].user
  step "I visit the user sign in page"
  step "I enter my email, password and click sign in"
end

Given(/^(?:the|that)(?: (\d+)\w+)? advocate signs in$/) do |cardinality|
  card = cardinality.nil? ? 1 : cardinality
  @user = @advocates[card.to_i-1].user
  step "I visit the user sign in page"
  step "I enter my email, password and click sign in"
end

Given(/^(?:the|that)(?: (\d+)\w+)? case worker signs in$/) do |cardinality|
  card = cardinality.nil? ? 1 : cardinality
  @user = @case_workers[card.to_i-1].user
  step "I visit the user sign in page"
  step "I enter my email, password and click sign in"
end

When(/^I enter my email, password and click sign in$/) do
  fill_in 'Email', with: (@user || User.first).email
  fill_in 'Password', with: @password || 'password'
  click_on 'Sign in'
  expect(page).to have_content('Sign out')
end

Then(/^I should be redirected to the "(.*?)" root url$/) do |namespace|
  case namespace.gsub(/\s/, '_')
    when 'case workers'
      expect(current_url).to eq(case_workers_root_url)
    when 'case workers admin'
      expect(current_url).to eq(case_workers_admin_root_url)
  end
end

Then(/^I should be redirected to the advocates root url$/) do
  expect(current_url).to eq(advocates_root_url)
end

Then(/^I should see the advocates correct working primary navigation$/) do
  step "I should see the advocates Your Claims link and it should work"
  step "I should see the advocates Archive link and it should work"
  step "I should see the advocates New Claim link and it should work"
end

Then(/^I should see the admin advocates correct working primary navigation$/) do
  step "I should see the admin advocates All Claims link and it should work"
  step "I should see the advocates Archive link and it should work"
  step "I should see the advocates New Claim link and it should work"
  step "I should see the advocates Admin link and it should work"
end

Then(/^I should see the advocates Your Claims link and it should work$/) do
  find('#primary-nav').click_link('Your Claims')
  expect(find('.page-title')).to have_content('Your Claims')
end

Then(/^I should see the admin advocates All Claims link and it should work$/) do
  find('#primary-nav').click_link('All Claims')
  expect(find('.page-title')).to have_content('All Claims')
end

Then(/^I should see the advocates Archive link and it should work$/) do
  find('#primary-nav').click_link('Archive')
  expect(find('h1')).to have_content('Archived Claims')
end

Then(/^I should see the advocates New Claim link and it should work$/) do
  find('#primary-nav').click_link('New Claim')
  expect(find('h1')).to have_content('Claim for Advocate Graduated Fees')
end

Then(/^I should see the advocates Admin link and it should work$/) do
  find('#primary-nav').click_link('Admin')
  expect(find('h1.page-title')).to have_content('Administration')
end

Then(/^I should see the caseworkers correct working primary navigation$/) do
  step "I should see the caseworkers Home link and it should work"
end

Then(/^I should see the admin caseworkers correct working primary navigation$/) do
  step "I should see the admin caseworkers Summary link and it should work"
  step "I should see the admin caseworkers Allocation link and it should work"
  step "I should see the admin caseworkers Admin link and it should work"
end

Then(/^I should see the caseworkers Home link and it should work$/) do
  find('#primary-nav').click_link('Home')
end

Then(/^I should see the admin caseworkers Summary link and it should work$/) do
  find('#primary-nav').click_link('Summary')
end

Then(/^I should see the admin caseworkers Allocation link and it should work$/) do
  find('#primary-nav').click_link('Allocation')
end

Then(/^I should see the admin caseworkers Admin link and it should work$/) do
  find('#primary-nav').click_link('Admin')
  expect(find('h1.page-title')).to have_content('Administration')
end
