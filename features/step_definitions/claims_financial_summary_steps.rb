Then(/^I should see my total value of outstanding claims$/) do
  expect(page).to have_content(@advocate.claims.outstanding.map(&:total).sum)
end

Then(/^I should see the total value of outstanding claims for my chamber$/) do
  expect(page).to have_content(@advocate.claims.outstanding.map(&:total).sum)
end

Then(/^I should see my total value of authorised claims$/) do
  expect(page).to have_content(@advocate.claims.authorised.map(&:total).sum)
end

Then(/^I should see the total value of authorised claims for my chamber$/) do
  expect(page).to have_content(@advocate.claims.authorised.map(&:total).sum)
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

When(/^I should see a list of authorised claims$/) do
  claim_dom_ids = @advocate.claims.authorised.map { |c| "claim_#{c.id}" }
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector("##{dom_id}")
  end
end
