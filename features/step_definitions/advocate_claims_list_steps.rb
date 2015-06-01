Given(/^I have claims$/) do
  @claims = create_list(:submitted_claim, 5, advocate: @advocate)
  @claims.each do |claim|
    claim.documents << create(:document, advocate: @advocate)
  end
  @other_claims = create_list(:submitted_claim, 3)
  @claims.each_with_index { |claim, index| claim.update_column(:total, index + 1) }
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
  @claims.each do |claim|
    claim.update_column(:advocate_id, advocate.id)
    claim.fees << create(:fee, :random_values, claim: claim, fee_type: create(:fee_type))
    if claim.state == 'completed'
      claim.update_column(:amount_assessed, claim.total)
    elsif claim.state == 'part_paid'
      claim.update_column(:amount_assessed, claim.total/2) # arbitrarily pay half the total for part-paid
    end
  end
end

Then(/^I see a column containing the amount assesed for "(.*?)" claims$/) do |state|
  within("##{state}") do
    expect(page).to have_content("Amount assessed")
  end
end

Then(/^a figure representing the amount assessed for "(.*?)" claims$/) do |state|
    within("##{state}") do
      rows = all('tr')
      rows.each do |row|
        claim = Claim.find_by(cms_number: row.text.split(' ')[3]) # find claim which corresponds to |row|
        expect(row.text.include?(claim.cms_number)).to be true # check that the correct claim was found
        expect(row.text.include?(claim.amount_assessed.round(2).to_s)).to be true
      end
    end
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
  claim_advocate = create(:advocate)
  claim_advocate.user.first_name = first_name
  claim_advocate.user.last_name = last_name
  claim_advocate.user.save!
  chamber = create(:chamber)
  chamber.advocates << advocate
  chamber.advocates << claim_advocate
  @claims = create_list(:claim, number.to_i)
  @claims.each { |claim| claim.update_column(:advocate_id, claim_advocate.id) }
end


Given(/^I should see section titles of "(.*?)"$/) do |section_title|
  expect(page).to have_selector('h2', text: section_title)
end

