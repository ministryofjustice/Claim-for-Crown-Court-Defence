
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
  step "I should see the advocates Your claims link and it should work"
  step "I should see the advocates Archive link and it should work"
  step "I should see the advocates Start a claim link and it should work"
end

Then(/^I should see the admin advocates correct working primary navigation$/) do
  step "I should see the admin advocates All claims link and it should work"
  step "I should see the advocates Archive link and it should work"
  step "I should see the advocates Start a claim link and it should work"
  step "I should see the admin advocates Manage advocates link and it should work"
  step "I should see the admin advocates Manage chamber link and it should work"
end

Then(/^I should see the advocates Your claims link and it should work$/) do
  find('#primary-nav').click_link('Your claims')
  expect(find('.page-title')).to have_content('Your claims')
end

Then(/^I should see the admin advocates All claims link and it should work$/) do
  find('#primary-nav').click_link('All claims')
  expect(find('.page-title')).to have_content('All claims')
end

Then(/^I should see the advocates Archive link and it should work$/) do
  find('#primary-nav').click_link('Archive')
  expect(find('h1')).to have_content('Archived claims')
end

Then(/^I should see the advocates Start a claim link and it should work$/) do
  find('#primary-nav').click_link('Start a claim')
  expect(find('h1')).to have_content('Claim for advocate graduated fees')
end

Then(/^I should see the admin advocates Manage advocates link and it should work$/) do
  find('#primary-nav').click_link('Manage advocates')
  expect(find('h1.page-title')).to have_content('Manage advocates')
end

Then(/^I should see the admin advocates Manage chamber link and it should work$/) do
  find('#primary-nav').click_link('Manage chamber')
  expect(find('h1.page-title')).to have_content("Manage chamber")
end

Then(/^I should see the caseworkers correct working primary navigation$/) do
  step "I should see the caseworkers Your claims link and it should work"
  step "I should see the caseworkers Archive link and it should work"
end

Then(/^I should see the admin caseworkers correct working primary navigation$/) do
  step "I should see the admin caseworkers Your claims link and it should work"
  step "I should see the admin caseworkers Archive link and it should work"
  step "I should see the admin caseworkers Allocation link and it should work"
  step "I should see the admin caseworkers Re-allocation link and it should work"
  step "I should see the admin caseworkers Manage case workers link and it should work"
end

Then(/^I should see the caseworkers Your claims link and it should work$/) do
  find('#primary-nav').click_link('Your claims')
  expect(find('h1.page-title')).to have_content('Your claims')
end

Then(/^I should see the caseworkers Archive link and it should work$/) do
  find('#primary-nav').click_link('Archive')
  expect(find('h1.page-title')).to have_content('Archived claims')
end

Then(/^I should see the admin caseworkers Your claims link and it should work$/) do
  find('#primary-nav').click_link('Your claims')
  expect(find('h1.page-title')).to have_content('Your claims')
end

Then(/^I should see the admin caseworkers Archive link and it should work$/) do
  find('#primary-nav').click_link('Archive')
  expect(find('h1.page-title')).to have_content('Archived claims')
end

Then(/^I should see the admin caseworkers Allocation link and it should work$/) do
  find('#primary-nav').click_link('Allocation')
  expect(find('h1.page-title')).to have_content('Allocation')
end

Then(/^I should see the admin caseworkers Re-allocation link and it should work$/) do
  find('#primary-nav').click_link('Re-allocation')
  expect(find('h1.page-title')).to have_content('Re-Allocation')
end

Then(/^I should see the admin caseworkers Manage case workers link and it should work$/) do
  find('#primary-nav').click_link('Manage case workers')
  expect(find('h1.page-title')).to have_content('Manage case workers')
end

When(/^I enter my email and the wrong password (\d+) times$/) do |attempts|
  attempts.to_i.times do
    fill_in 'Email', with: (@user || User.first).email
    fill_in 'Password', with: 'non-existent-password'
    click_on 'Sign in'
    expect(page).to have_content('Sign in')
  end
end

Then(/^I should no longer be able to sign in$/) do
  fill_in 'Email', with: (@user || User.first).email
  fill_in 'Password', with: @password || 'password'
  click_on 'Sign in'
  expect(page).to have_content('Sign in')
  expect(User.first.locked_at).to be > 5.minutes.ago
end

When(/^the (\d+) minute lockout duration has expired then I should be able to sign in again$/) do |duration|
  Timecop.freeze(duration.to_i.minutes.from_now) do
    fill_in 'Email', with: (@user || User.first).email
    fill_in 'Password', with: @password || 'password'
    click_on 'Sign in'
    expect(page).to have_content('Sign out')
  end
end
