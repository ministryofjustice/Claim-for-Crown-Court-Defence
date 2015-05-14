Given(/^I am a signed in admin$/) do
  admin = create(:case_worker, :admin)
  visit new_user_session_path
  sign_in(admin, 'password')
end

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
  select @claims.first.case_number, from: 'case_worker_claim_ids'
  select @claims.second.case_number, from: 'case_worker_claim_ids'
  click_on 'Update Case worker'
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
