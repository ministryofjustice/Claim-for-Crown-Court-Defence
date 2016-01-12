Given(/^I have authorised and part authorised claims$/) do
  @claims = create_list(:authorised_claim, 2, external_user: @advocate)
  @claims += create_list(:part_authorised_claim, 3, external_user: @advocate)
  @other_claims = create_list(:allocated_claim, 3)
end

Given(/^my provider has authorised and part authorised claims$/) do
  another_advocate = create(:external_user, :advocate)
  @advocate.provider.external_users << another_advocate
  @claims = create_list(:authorised_claim, 2)
  @claims += create_list(:part_authorised_claim, 1)
  @claims.each { |claim| claim.update_column(:external_user_id, another_advocate.id) }
  @other_claims = create_list(:allocated_claim, 3)
  @other_claims.each { |claim| claim.update_column(:external_user_id, another_advocate.id) }
end

Then(/^I should see my total value of outstanding claims$/) do
  expect(page).to have_content(@advocate.claims.outstanding.map(&:total_including_vat).sum)
end

Then(/^I should see the total value of outstanding claims for my provider$/) do
  expect(page).to have_content(@advocate.claims.outstanding.map(&:total).sum)
end

Then(/^I should see my total value of authorised and part authorised claims$/) do
  total = ActiveSupport::NumberHelper.number_to_delimited(@advocate.claims.any_authorised.map(&:amount_assessed).sum.round(2))
  expect(page).to have_content(total)
end

Then(/^I should see the total value of authorised and part authorised claims for my provider$/) do
  expect(page).to have_content(@advocate.claims.any_authorised.map(&:total).sum)
end

When(/^click on the link to view the details of outstanding claims$/) do
  click_link 'outstanding_claim_details'
end

Then(/^I should see a list of outstanding claims$/) do
  claim_dom_ids = @advocate.claims.outstanding.map { |c| "claim_#{c.id}" }
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector("##{dom_id}")
  end
end

When(/^click on the link to view the details of authorised claims$/) do
  click_link 'authorised_claim_details'
end

When(/^I should see a list of authorised and part authorised claims$/) do
  expect(page).not_to have_content('No claims found')
  expect(page).not_to have_content('Allocated')
  claim_dom_ids = @advocate.claims.any_authorised.map { |c| "claim_#{c.id}" }
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector("##{dom_id}")
  end
end
