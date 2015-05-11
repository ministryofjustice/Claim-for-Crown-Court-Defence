Given(/^I have claims$/) do
  advocate = Advocate.first
  @claims = create_list(:claim, 5)
  @other_claims = create_list(:claim, 3)
  @claims.each_with_index { |claim, index| claim.update_column(:total, index + 1) }
  @claims.each { |claim| claim.update_column(:advocate_id, advocate.id) }
  create(:defendant, maat_reference: 'AA1245', claim_id: @claims.first.id)
  create(:defendant, maat_reference: 'BB1245', claim_id: @claims.second.id)
end

When(/^I visit the advocates dashboard$/) do
  visit advocates_claims_path
end

Then(/^I should see only claims that I have created$/) do
  claim_dom_ids = @claims.map { |c| "claim_#{c.id}" }
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector("##{dom_id}")
  end

  other_claim_dom_ids = @other_claims.map { |c| "claim_#{c.id}" }
  other_claim_dom_ids.each do |dom_id|
    expect(page).to_not have_selector("##{dom_id}")
  end
end

Given(/^I am a signed in advocate admin$/) do
  advocate = create(:advocate, :admin)
  visit new_user_session_path
  sign_in(advocate.user, 'password')
end

Given(/^my chamber has claims$/) do
  advocate = Advocate.first
  another_advocate = create(:advocate)
  chamber = create(:chamber)
  chamber.advocates << advocate
  @claims = create_list(:claim, 5)
  @claims.each { |claim| claim.update_column(:advocate_id, another_advocate.id) }
  @other_claims = create_list(:claim, 3)
end

Then(/^I should see my chamber's claims$/) do
  chamber = Chamber.first
  claim_dom_ids = chamber.claims.map { |c| "claim_#{c.id}" }
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector("##{dom_id}")
  end

  other_claim_dom_ids = @other_claims.map { |c| "claim_#{c.id}" }
  other_claim_dom_ids.each do |dom_id|
    expect(page).to_not have_selector("##{dom_id}")
  end
end
