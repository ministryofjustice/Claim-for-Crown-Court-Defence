

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
  step "I enter my email, password and click log in"
end

Given(/^(?:the|that)(?: (\d+)\w+)? advocate signs in$/) do |cardinality|
  card = cardinality.nil? ? 1 : cardinality
  @user = @advocates[card.to_i-1].user
  step "I visit the user sign in page"
  step "I enter my email, password and click log in"
end

Given(/^(?:the|that)(?: (\d+)\w+)? case worker signs in$/) do |cardinality|
  card = cardinality.nil? ? 1 : cardinality
  @user = @case_workers[card.to_i-1].user
  step "I visit the user sign in page"
  step "I enter my email, password and click log in"
end

When(/^I enter my email, password and click log in$/) do
  fill_in 'Email', with: (@user || User.first).email
  fill_in 'Password', with: @password || 'password'
  click_on 'Log in'
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

Then(/^I should be redirected to the advocates landing url$/) do
  expect(current_url).to eq(advocates_landing_url)
end

Then(/^I should be redirected to the advocates root url$/) do
  expect(current_url).to eq(advocates_root_url)
end


