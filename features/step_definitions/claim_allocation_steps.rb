
Given(/^(\d+) case workers? exists?$/) do |quantity|
  @case_workers = create_list(:case_worker, quantity.to_i)
end

Given(/^(\d+) submitted claims? exists?$/) do |quantity|
  @claims = create_list(:submitted_claim, quantity.to_i)
end

When(/^I visit the allocation page$/) do
  visit case_workers_admin_allocations_path
end

When(/^I select claims$/) do
  check(@claims.first.case_number)
  check(@claims.second.case_number)
end

When(/^I select a case worker$/) do
  select @case_workers.first.name, from: 'allocation_case_worker_id'
end

Then(/^the claims should be allocated to the case worker$/) do
  expect(@case_workers.first.claims).to match_array([@claims.first, @claims.second])
  @case_workers.first.claims.each do |claim|
    expect(claim).to be_allocated
  end
end

When(/^I click Allocate$/) do
  click_on('Allocate', match: :first)
end

Then(/^the allocated claims should no longer be displayed$/) do
  @claims[0..1].each do |claim|
    expect(page).to_not have_selector("#claim_#{claim.id}")
  end
end

Then(/^I should see a summary of the claims that were allocated$/) do
  within '.allocated-summary' do
    expect(page).to have_content(/\d+ claims? allocated to #{@case_workers.first.name}/)
    @claims[0..1].each do |claim|
      expect(page).to have_content("Case number: #{claim.case_number}")
    end
  end
end

When(/^I enter (\d+) in the quantity text field$/) do |quantity|
  fill_in 'quantity_to_allocate', with: quantity
end

Then(/^the first (\d+) claims in the list should be allocated to the case worker$/) do |quantity|
  expect(@case_workers.first.claims.count).to eq(quantity.to_i)

  @case_workers.first.claims.each do |claim|
    expect(claim).to be_allocated
  end
end

Then(/^the first (\d+) claims should no longer be displayed$/) do |quantity|
  @case_workers.first.claims.each do |claim|
    expect(page).to_not have_selector("#claim_#{claim.id}")
  end
end
