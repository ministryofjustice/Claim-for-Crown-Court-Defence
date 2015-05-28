Given(/^I have claims$/) do
  advocate = Advocate.first
  @claims = create_list(:submitted_claim, 5)
  @claims.each do |claim|
    claim.documents << create(:document, advocate: advocate)
  end
  @other_claims = create_list(:submitted_claim, 3)
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
  @advocate = create(:advocate, :admin)
  visit new_user_session_path
  sign_in(@advocate.user, 'password')
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

Given(/^my chamber has (\d+) "(.*?)" claims$/) do |number, state|
  advocate = Advocate.first
  chamber = Chamber.first
  chamber.advocates << advocate

  @claims = state == 'draft' ? create_list(:claim, number.to_i) : create_list("#{state}_claim".to_sym, number.to_i)
  @claims.each { |claim| claim.update_column(:advocate_id, advocate.id) }
end

Then(/^I should see my chamber's (\d+) "(.*?)" claims$/) do |number, state|
  chamber = Chamber.first

  claim_dom_ids = chamber.claims.send(state.to_sym).map { |c| "claim_#{c.id}" }

  expect(claim_dom_ids.size).to eq(number.to_i)

  within "##{state}" do
    claim_dom_ids.each do |dom_id|
      expect(page).to have_selector("##{dom_id}")
    end
  end
end

When(/^I search by the advocate name "(.*?)"$/) do |name|
  fill_in 'search', with: name
  click_button 'Search'
end

Then(/^I should only see the (\d+) claims for the advocate "(.*?)"$/) do |number, name|
  expect(page).to have_content(name, count: number.to_i)
end

Then(/^I should not see the advocate search field$/) do
  expect(page).to_not have_selector('#search')
end

Given(/^my chamber has (\d+) claims for advocate "(.*?)"$/) do |number, advocate_name|
  advocate = Advocate.first
  first_name = advocate_name.split.first
  last_name = advocate_name.split.last
  claim_advocate = create(:advocate, first_name: first_name, last_name: last_name)
  chamber = create(:chamber)
  chamber.advocates << advocate
  chamber.advocates << claim_advocate
  @claims = create_list(:claim, number.to_i)
  @claims.each { |claim| claim.update_column(:advocate_id, claim_advocate.id) }
end
