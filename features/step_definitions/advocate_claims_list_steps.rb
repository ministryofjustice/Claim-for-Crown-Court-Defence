Given(/^I have claims$/) do
  FactoryGirl.create :vat_rate
  @claims = create_list(:submitted_claim, 5, advocate: @advocate)
  @claims.each do |claim|
    claim.documents << create(:document, advocate: @advocate)
  end
  @other_claims = create_list(:submitted_claim, 3)
  @claims.each_with_index { |claim, index| claim.update(total: index + 1, fees_total: index + 1, expenses_total: 0) }
  create :defendant, claim_id: @claims.first.id, representation_orders: [ FactoryGirl.create(:representation_order, maat_reference: '0123456789') ]
  create :defendant, claim_id: @claims.second.id, representation_orders: [ FactoryGirl.create(:representation_order, maat_reference: '2078352232') ]
end

When(/^I visit the advocates dashboard$/) do
  visit advocates_claims_path
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

Given(/^I have (\d+) claims of each state$/) do | claims_per_state |
  # create n claims for all states except deleted and archived_pending_delete
  states = Claim.state_machine.states.map(&:name)
  states = states.map { |s| if s != :deleted && s != :archived_pending_delete then  s; end; }.compact
  states.each do | state |
    claims = create_list("#{state}_claim".to_sym, claims_per_state.to_i, advocate: @advocate)
  end
end

Given(/^my chamber has (\d+) "(.*?)" claims$/) do |number, state|
  advocate = Advocate.first
  chamber = Chamber.first
  chamber.advocates << advocate

  claims = state == 'draft' ? create_list(:claim, number.to_i) : create_list("#{state}_claim".to_sym, number.to_i)
  claims.each do |claim|
    claim.update_column(:advocate_id, advocate.id)
    claim.fees << create(:fee, :random_values, claim: claim, fee_type: create(:fee_type))
    if claim.state == 'authorised'
      claim.assessment.update(fees: claim.total)
    elsif claim.state == 'part_authorised'
      claim.assessment.update(fees: claim.total / 2)     # arbitrarily authorise half the total for part-authorised
    end
  end
end

Given(/^my chamber has (\d+) "(.*?)" claims for advocate "(.*?)"$/) do |number, state, advocate_name|
  # add advocate to my chamber
  advocate = create_advocate_with_full_name(advocate_name)
  chamber = @advocate.chamber
  chamber.advocates << advocate
  chamber.save!

  # add claim(s) to the new advocate
  claims =  (state == 'draft' ? create_list(:claim, number.to_i) : create_list("#{state}_claim".to_sym, number.to_i))
  claims.each do |claim|
    claim.update_column(:advocate_id, advocate.id)
    claim.fees << create(:fee, :random_values, claim: claim, fee_type: create(:fee_type))
    if claim.state == 'completed'
      claim.assessment.update(fees: claim.total)
    elsif claim.state == 'part_authorised'
      claim.assessment.update(fees: claim.total / 2)     # arbitrarily authorise half the total for part-authorised
    end
  end

end

Given(/^my chamber has (\d+) claims for advocate "(.*?)"$/) do |number, advocate_name|
  advocate = Advocate.first
  claim_advocate = create_advocate_with_full_name(advocate_name)
  chamber = create(:chamber)
  chamber.advocates << advocate
  chamber.advocates << claim_advocate
  claims = create_list(:claim, number.to_i)
  claims.each { |claim| claim.update_column(:advocate_id, claim_advocate.id) }
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
        within(row) do
          cms = all('td')[3].text
          claim = Claim.find_by(cms_number: cms) # find claim which corresponds to |row|
          expect(claim.cms_number).to eq cms # check that the correct claim was found
          expect(row.text.include?(ActionController::Base.helpers.number_to_currency(claim.assessment.total))).to be true
        end
      end
    end
end

When(/^I search by the name "(.*?)"$/) do |name|
  fill_in 'search', with: name
  click_button 'Search'
end

Given(/^I have (\d+) "(.*?)" claims$/) do |number,state|
  @claims = create_list("#{state}_claim".to_sym, number.to_i, advocate: @advocate)
end

Given(/^I have (\d+) claims involving defendant "(.*?)"$/) do |number,defendant_name|
  @claims = create_list(:submitted_claim, number.to_i, advocate: @advocate)
  @claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
end

Given(/^I, advocate, have (\d+) "(.*?)" claims involving defendant "(.*?)"$/) do |number, state, defendant_name|
  @claims = create_list("#{state}_claim".to_sym, number.to_i, advocate: @advocate)
  @claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
end

Given(/^I should see section titles of "(.*?)"$/) do |section_title|
  expect(page).to have_selector('h2', text: section_title)
end

Given(/^signed in advocate's chamber has (\d+) claims for advocate "(.*?)" with defendant "(.*?)"$/) do |number, advocate_name, defendant_name|
  new_advocate = create_advocate_with_full_name(advocate_name, @advocate.chamber)
  new_advocate.chamber = @advocate.chamber
  claims = create_list(:submitted_claim, number.to_i, advocate: new_advocate )
  claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
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

Then(/^I should see my chamber's (\d+) "(.*?)" claims$/) do |number, state|
  chamber = Chamber.first
  claim_dom_ids = chamber.claims.send(state.to_sym).map { |c| "claim_#{c.id}" }

  expect(claim_dom_ids.size).to eq(number.to_i)

  within('.report') do
    #look through the tbody part of the report
    expect(find(:xpath, './tbody')).to have_content(state.humanize, count: number.to_i)
  end

  expect(page).to have_selector(".#{state}", count: number.to_i)
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector("##{dom_id}")
  end

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

Then(/^I should only see the (\d+) claims for the advocate "(.*?)"$/) do |number, name|
  expect(page).to have_content(/#{number} claims? of #{number} matching "#{name}"/)
end

Then(/^I should only see the (\d+) claims involving defendant "(.*?)"$/) do |number, name|
  expect(page).to have_content(/#{number} claims? of #{number} matching "#{name}"/)
end

Then(/^I should NOT see column "(.*?)" under section id "(.*?)"$/) do |column_name, section_id|
  node = find("section##{section_id}").find('.report')
  expect(node).not_to have_selector('th', text: column_name)
end

Then(/^I should not see archived claims listed$/) do
  expect(page).not_to have_content('Archived pending delete')
end

Then(/^I should see (\d+) "(.*?)" claims listed$/) do |number, state|
  expect(page).to have_selector(".#{state}", count: number)
end

# local helpers
# ------------------

def create_advocate_with_full_name(full_name)
  advocate = create(:advocate)
  advocate.user.first_name = full_name.split.first
  advocate.user.last_name = full_name.split.last
  advocate.user.save!
  advocate
end
