
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
  click_on('Allocate', match: :smart)
end

Then(/^the allocated claims should no longer be displayed$/) do
  @claims[0..1].each do |claim|
    expect(page).to_not have_selector("#claim_#{claim.id}")
  end
end

Then(/^I should see a notification of the claims that were allocated$/) do
  within '.allocated-summary' do
    expect(page).to have_content(/#{Claim.allocated.count} claims? allocated to #{@case_workers.first.name}/)
  end
end

When(/^I enter (\d+) in the quantity text field$/) do |quantity|
  within('table.claims_table') do
    @case_numbers = all('label.case-number').map(&:text)
  end
  @claims_on_page = []
  @case_numbers.each do |case_number|
    @claims_on_page << Claim.find_by(case_number: case_number)
  end
  @claims_to_allocate = @claims_on_page.take(quantity.to_i)
  fill_in 'quantity_to_allocate', with: quantity
end

Then(/^the first (\d+) claims in the list should be allocated to the case worker$/) do |quantity|
  expect(@case_workers.first.claims.count).to eq(quantity.to_i)

  @case_workers.first.claims.each do |claim|
    expect(claim).to be_allocated
  end

  expect(@case_workers.first.claims.map(&:id)).to match_array @claims_to_allocate.map(&:id)

end

Then(/^the first (\d+) claims should no longer be displayed$/) do |quantity|
  @case_workers.first.claims.each do |claim|
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
  claims = type == 'all' ? Claim.all : Claim.send(type.to_sym)
  claims.each { |claim| expect(page).to have_selector("#claim_#{claim.id}") }

  expect(claims.count).to eq(quantity.to_i)

  within '.claim-count' do
    expect(page).to have_content(/Number of claims: #{quantity}?/)
  end
end

Then(/^I should see all claims$/) do
  @claims.each do |claim|
    expect(page).to have_selector("#claim_#{claim.id}")
  end
end

Then(/^I should not see any redetermination or awaiting_written_reasons claims$/) do
  claims = Claim.redetermination + Claim.awaiting_written_reasons
  claims.each do |claim|
    expect(page).to_not have_selector("#claim_#{claim.id}")
  end
end
