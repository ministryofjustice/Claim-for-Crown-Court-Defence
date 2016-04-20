Given(/^case worker "(.*?)" exists$/) do |name|
  @password = "password"
  first_name = name.split.first
  last_name = name.split.last
  @case_worker_user = create(:user, first_name: first_name, last_name: last_name,
                password: @password, password_confirmation: @password)
  create(:case_worker, :case_worker, user: @case_worker_user)
end

When(/^I sign in as John Smith$/) do
  sign_in(@case_worker_user, @password)
end

Then(/^I should be on the 'Your claims' page$/) do
  expect(page).to have_content("Your claims")
end

Then(/^claims "([^"]*)" should appear on the page$/) do |case_numbers|
  @external_user_home_page.includes_all_claims?(case_numbers)
end

When(/^I select claims "(.*?)"$/) do |case_numbers|
  sleep 5
  @allocation_page.select_claims(case_numbers)
end

When(/^I select case worker "(.*?)"$/) do |name|
  @allocation_page.select_case_worker(name)
end

Then(/^claims? "(.*?)" should be allocated to case worker "(.*?)"$/) do |case_numbers, name|
  case_worker = User.where(first_name: name.split.first, last_name: name.split.last).first.persona
  case_numbers = case_numbers.split(',').map(&:strip)
  expect(case_worker.claims.map(&:case_number)).to match_array(case_numbers)
end

Then(/^(\d+) claims should be allocated to case worker "(.*?)"$/) do |quantity, name|
  case_worker = User.where(first_name: name.split.first, last_name: name.split.last).first.persona
  expect(case_worker.claims.count).to eq(quantity.to_i)
end

Then(/^claims? "(.*?)" should no longer be displayed$/) do |case_numbers|
  expect(@allocation_page.includes_any_cases?(case_numbers)).to eq(false)
end

Then(/^the (\d+) allocated claims should no longer be displayed$/) do |quantity|
  quantity.to_i.times do |n|
    expect(page).to_not have_selector("#claim_#{@claims[n].id}")
  end
end

Given(/^claims "(.*?)" have been allocated to "(.*?)"$/) do |case_numbers, name|
  case_worker = User.where(first_name: name.split.first, last_name: name.split.last).first.persona
  case_numbers = case_numbers.split(',').map(&:strip)
  claims = Claim::BaseClaim.where(case_number: case_numbers)
  case_worker.claims << claims
end

Then(/^I should see a notification (\d+) claims were allocated to "(.*?)"$/) do |quantity, name|
  within '.notice-summary' do
    expect(page).to have_content(/#{quantity} claims? allocated to #{name}/)
  end
end

Given(/^submitted claims? exists? with case numbers? "(.*?)$/) do |case_numbers|
  case_numbers = case_numbers[0..-2].split(',').map(&:strip)
  @claims = []

  case_numbers.each do |case_number|
    @claims << create(:submitted_claim, case_number: case_number)
  end
end

When(/^I visit the allocation page$/) do
  @allocation_page.load
end

Then(/^I visit the re\-allocation page$/) do
  visit case_workers_admin_allocations_path(tab: 'allocated')
end

When(/^I click Allocate$/) do
  @allocation_page.allocate.click
end

When(/^I enter (\d+) in the quantity text field$/) do |quantity|
  within('.report') do
    @case_numbers = all('.js-test-case-number').map(&:text)
  end
  @claims_on_page = []
  @case_numbers.each do |case_number|
    @claims_on_page << Claim::BaseClaim.find_by(case_number: case_number)
  end
  @claims_to_allocate = @claims_on_page.take(quantity.to_i)
  fill_in 'quantity_to_allocate', with: quantity
end

Then(/^the first (\d+) claims in the list should be allocated to the case worker$/) do |quantity|
  expect(CaseWorker.last.claims.count).to eq(quantity.to_i)
  CaseWorker.last.claims.each do |claim|
    expect(claim).to be_allocated
  end

  expect(CaseWorker.last.claims.map(&:id)).to match_array @claims_to_allocate.map(&:id)

end

Then(/^the first (\d+) claims should no longer be displayed$/) do |quantity|
  CaseWorker.last.claims.each do |claim|
    expect(page).to_not have_selector("#claim_#{claim.id}")
  end
end

Given(/^there are (\d+) "(.*?)" claims?$/) do |quantity, type|

  number = quantity.to_i

  case type
    when 'all'
      # create_list(:submitted_claim, number) - commented out because 10 claims are created in the background to this feature
    when 'fixed_fee'
      claims = create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Contempt').id)
    when 'trial'
      create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Trial').id)
    when 'cracked'
      create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Cracked Trial').id)
    when 'guilty_plea'
      create_list(:submitted_claim, number, case_type_id: CaseType.by_type('Guilty plea').id)
    when 'redetermination'
      create_list(:redetermination_claim, number)
    when 'awaiting_written_reasons'
      create_list(:awaiting_written_reasons_claim, number)
  end
end

When(/^I filter by "(.*?)"$/) do |filter|
  choose filter.humanize
  click_on 'Filter'
end

Then(/^I should only see (\d+) "(.*?)" claims? after filtering$/) do |quantity, type|
  claims = type == 'all' ? Claim::BaseClaim.all : Claim::BaseClaim.send(type.to_sym)
  claims.each { |claim| expect(page).to have_selector("#claim_#{claim.id}") }
  expect(claims.count).to eq(quantity.to_i)
end

Then(/^I should not see any redetermination or awaiting_written_reasons claims$/) do
  claims = Claim::BaseClaim.redetermination + Claim::BaseClaim.awaiting_written_reasons
  claims.each do |claim|
    expect(page).to_not have_selector("#claim_#{claim.id}")
  end
end

When(/^I click on a claim row cell$/) do
  within('.report') do
    #click first row's 2nd column
    page.find('tbody').all('tr')[0].all('td')[1].click()
  end
end

When(/^I click on a claims row cell$/) do
  #click the first row's first 2nd cell
  page.find('tbody').all('tr')[0].all('td')[1].click()
end

Then (/^I should see that claims checkbox (ticked|unticked)$/) do | checkbox_state|
  if checkbox_state == 'ticked'
    expect(page.find('tbody').all('tr')[0].all('input[type=checkbox]')[0]).to be_checked
  else
    expect(page.find('tbody').all('tr')[0].all('input[type=checkbox]')[0]).not_to be_checked
  end
end

When(/^I click Re\-allocate$/) do
  click_on('Re-allocate', match: :smart)
end

Given(/^I choose the "(.*?)" option$/) do |label|
  choose label
end

Then(/^I should no longer see the case workers dropdown$/) do
  within '.js-case-worker-list' do
    expect(page).to_not have_selector('#allocation_case_worker_id')
    expect(page).to_not have_content('Case worker')
  end
end

Then(/^I should see a notification that (\d+) claims were deallocated$/) do |quantity|
  within '.notice-summary' do
    expect(page).to have_content(/#{quantity} claims? returned to allocation pool/)
  end
end
