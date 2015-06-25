
Given(/^a case worker exists$/) do
  @case_worker = create(:case_worker)
end

Given(/^submitted claims exist$/) do
  @claims = create_list(:submitted_claim, 5)
end

When(/^I visit the case worker allocation page$/) do
  visit allocate_case_workers_admin_case_worker_path(@case_worker)
end

When(/^I allocate claims$/) do
  check(@claims.first.case_number)
  check(@claims.second.case_number)
  click_on 'Update Case worker'

  @allocated_claim_1 = @claims.first
  @allocated_claim_2 = @claims.second
end

Then(/^the case worker should have claims allocated to them$/) do
  expect(@case_worker.claims).to match_array([@claims.first, @claims.second])
end

Then(/^the claims should be visible on the case worker's dashboard$/) do
  visit case_workers_root_path
  click_on 'Sign out'
  visit new_user_session_path
  sign_in(@case_worker, 'password')
  claim_dom_ids = @case_worker.claims.map { |claim| "#claim_#{claim.id}" }
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector(dom_id)
  end
end

When(/^I remove the caseworker$/) do
  visit case_workers_admin_case_workers_path
  within "#case_worker_#{@case_worker.id}" do
    click_on 'Delete'
  end
end

Then(/^the claims should not be assigned to any case workers$/) do
  expect(@claims.map(&:case_workers).flatten).to be_empty
end

Then(/^the claims should be in an allocated state$/) do
  expect(@allocated_claim_1.reload).to be_allocated
  expect(@allocated_claim_2.reload).to be_allocated
end

Given(/^a new claim has been submitted$/) do
  @claim = create(:submitted_claim)
end

Then(/^I should see the new claim at the bottom of the list$/) do
  expect(all("input[type='checkbox']").last[:id]).to eq("case_worker_claim_ids_#{@claim.id}")
end
