Given(/^I am a signed in admin$/) do
  admin = create(:admin, password: 'password', password_confirmation: 'password')
  visit new_user_session_path
  sign_in(admin, 'password')
end

Given(/^a case worker exists$/) do
  @case_worker = create(:case_worker, password: 'password', password_confirmation: 'password')
end

Given(/^submitted claims exist$/) do
  @claims = create_list(:submitted_claim, 5)
end

When(/^I visit the case worker allocation page$/) do
  visit allocate_admin_user_path(@case_worker)
end

When(/^I allocate claims$/) do
  select @claims.first.case_number, from: 'user_claims_to_manage_ids'
  select @claims.second.case_number, from: 'user_claims_to_manage_ids'
  click_on 'Update User'
end

Then(/^the case worker should have claims allocated to them$/) do
  expect(@case_worker.claims_to_manage).to match_array([@claims.first, @claims.second])
end

Then(/^the claims should be visible on the case worker's dashboard$/) do
  click_on 'Sign out'
  visit new_user_session_path
  sign_in(@case_worker, 'password')
  claim_dom_ids = @case_worker.claims_to_manage.map { |claim| "#claim_#{claim.id}" }
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector(dom_id)
  end
end
