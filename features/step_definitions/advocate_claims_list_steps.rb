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

Given(/^There are basic and non-basic fee types$/) do
  create :fee_type, :basic
  create :fee_type, :misc
  create :fee_type, :fixed
  create :fee_type, :basic
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

Then(/^I see a column called amount assesed for "(.*?)" claims$/) do |state|
  within("##{state}") do
    expect(page).to have_content("Amount assessed")
  end
end

Then(/^I do not see a column called amount assesed for "(.*?)" claims$/) do |state|
  within("##{state}") do
    expect(page).to_not have_content("Amount assessed")
  end
end

Then(/^I see a column containing the amount assessed for "(.*?)" claims$/) do |state|
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
  select 'Advocate', from: 'search_field'
  fill_in 'search', with: name
  click_button 'Search'
end

Then(/^I should only see the (\d+) claims for the advocate "(.*?)"$/) do |number, name|
  expect(page).to have_content(/#{number} claims? matching Advocate "#{name}"/)
end

Then(/^I should not see the advocate search field$/) do
  expect(page).to_not have_selector('#search_advocate')
end

When(/^I search by the defendant name "(.*?)"$/) do |name|
  select 'Defendant', from: 'search_field'
  fill_in 'search', with: name
  click_button 'Search'
end

When(/^I search by the name "(.*?)"$/) do |name|
  fill_in 'search', with: name
  click_button 'Search'
end

Then(/^I should only see the (\d+) claims involving defendant "(.*?)"$/) do |number, name|
  expect(page).to have_content(/#{number} claims? matching Defendant "#{name}"/)
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

Given(/^I have (\d+) claims involving defendant "(.*?)" amongst others$/) do |number,defendant_name|
  @claims = create_list(:draft_claim, number.to_i, advocate: @advocate)
  @claims.each do |claim|
    create(:defendant, claim: claim, first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)
  end
  @claims = create_list(:submitted_claim, number.to_i, advocate: @advocate)
  @claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
end

Given(/^I should see section titles of "(.*?)"$/) do |section_title|
  expect(page).to have_selector('h2', text: section_title)
end

Given(/^signed in advocate's chamber has (\d+) claims for advocate "(.*?)" with defendant "(.*?)"$/) do |number, advocate_name, defendant_name|
  new_advocate = create(:advocate, chamber: @advocate.chamber)
  new_advocate.user.first_name = advocate_name.split.first
  new_advocate.user.last_name = advocate_name.split.last
  new_advocate.user.save!

  claims = create_list(:submitted_claim, number.to_i, advocate: new_advocate )
  claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
end

When(/^I enter advocate name of "(.*?)"$/) do |name|
  select 'Advocate', from: 'search_field'
  fill_in 'search', with: name
end

When(/^I enter defendant name of "(.*?)"$/) do |name|
  select 'Defendant', from: 'search_field'
  fill_in 'search', with: name
end

When (/^I hit search button$/) do
  click_button 'Search'
end

Given(/^I have (\d+) claims of each state$/) do | claims_per_state |
  # create n claims for all states except deleted and archived_pending_delete
  states = Claim.state_machine.states.map(&:name)
  states = states.map { |s| if s != :deleted && s != :archived_pending_delete then  s; end; }.compact
  states.each do | state |
    claims = create_list("#{state}_claim".to_sym, claims_per_state.to_i, advocate: @advocate)
  end
end

Then(/^I should NOT see column "(.*?)" under section id "(.*?)"$/) do |column_name, section_id|
  node = find("section##{section_id}").find('.claims_table')
  expect(node).not_to have_selector('th', text: column_name)
end
