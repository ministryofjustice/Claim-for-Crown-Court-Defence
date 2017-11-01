Given(/^I have claims$/) do
  FactoryBot.create :vat_rate
  @claims = create_list(:submitted_claim, 5, external_user: @advocate)
  @claims.each do |claim|
    claim.documents << create(:document, external_user: @advocate)
  end
  @other_claims = create_list(:submitted_claim, 3)
  @claims.each_with_index { |claim, index| claim.update(total: index + 1, fees_total: index + 1, expenses_total: 0) }
  create :defendant, claim_id: @claims.first.id, representation_orders: [ FactoryBot.create(:representation_order, maat_reference: '0123456789') ]
  create :defendant, claim_id: @claims.second.id, representation_orders: [ FactoryBot.create(:representation_order, maat_reference: '2078352232') ]
end

When(/^I visit the advocates dashboard$/) do
  visit external_users_claims_path
end

Given(/^There are basic and non-basic fee types$/) do
  create :basic_fee_type
  create :misc_fee_type
  create :fixed_fee_type
  create :basic_fee_type
end

Given(/^my provider has claims$/) do
  advocate = ExternalUser.first
  another_advocate = create(:external_user, :advocate)
  provider = create(:provider)
  provider.external_users << advocate
  @claims = create_list(:claim, 5)
  @claims.each { |claim| claim.update_column(:external_user_id, another_advocate.id) }
  @other_claims = create_list(:claim, 3)
end

Given(/^I have (\d+) claims of each state$/) do | claims_per_state |
  # create n claims for all states except deleted and archived_pending_delete
  states = Claim::BaseClaim.state_machine.states.map(&:name)
  states = states.map { |s| if s != :deleted && s != :archived_pending_delete then  s; end; }.compact
  states.each do | state |
    claims = create_list("#{state}_claim".to_sym, claims_per_state.to_i, external_user: @advocate)
  end
end

Given(/^my provider has (\d+) "(.*?)" claims$/) do |number, state|
  advocate = ExternalUser.first
  provider = Provider.first
  provider.external_users << advocate

  claims = state == 'draft' ? create_list(:claim, number.to_i) : create_list("#{state}_claim".to_sym, number.to_i)
  claims.each do |claim|
    claim.update_column(:external_user_id, advocate.id)
    claim.fees << create(:misc_fee, :random_values, claim: claim)
    if claim.state == 'authorised'
      claim.assessment.update(fees: claim.total)
    elsif claim.state == 'part_authorised'
      claim.assessment.update(fees: claim.total / 2)     # arbitrarily authorise half the total for part-authorised
    end
  end
end

Given(/^my provider has (\d+) "(.*?)" claims for advocate "(.*?)"$/) do |number, state, advocate_name|
  # add advocate to my provider
  advocate = create_advocate_with_full_name(advocate_name)
  provider = @advocate.provider
  provider.external_users << advocate
  provider.save!

  # add claim(s) to the new advocate
  claims =  (state == 'draft' ? create_list(:claim, number.to_i) : create_list("#{state}_claim".to_sym, number.to_i))
  claims.each do |claim|
    claim.update_column(:external_user_id, advocate.id)
    claim.fees << create(:misc_fee, :random_values, claim: claim)
    if claim.state == 'completed'
      claim.assessment.update(fees: claim.total)
    elsif claim.state == 'part_authorised'
      claim.assessment.update(fees: claim.total / 2)     # arbitrarily authorise half the total for part-authorised
    end
  end

end

Given(/^my provider has (\d+) claims for advocate "(.*?)"$/) do |number, advocate_name|
  advocate = ExternalUser.first
  claim_advocate = create_advocate_with_full_name(advocate_name)
  provider = create(:provider)
  provider.external_users << advocate
  provider.external_users << claim_advocate
  claims = create_list(:claim, number.to_i)
  claims.each { |claim| claim.update_column(:external_user_id, claim_advocate.id) }
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
          claim = Claim::BaseClaim.find_by(cms_number: cms) # find claim which corresponds to |row|
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
  @claims = create_list("#{state}_claim".to_sym, number.to_i, external_user: @advocate)
end

Given(/^I have (\d+) claims involving defendant "(.*?)"$/) do |number,defendant_name|
  @claims = create_list(:submitted_claim, number.to_i, external_user: @advocate)
  @claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
end

Given(/^I, advocate, have (\d+) "(.*?)" claims involving defendant "(.*?)"$/) do |number, state, defendant_name|
  @claims = create_list("#{state}_claim".to_sym, number.to_i, external_user: @advocate)
  @claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
end

Given(/^I should see section titles of "(.*?)"$/) do |section_title|
  expect(page).to have_selector('h2', text: section_title)
end

Given(/^signed in advocate's provider has (\d+) claims for advocate "(.*?)" with defendant "(.*?)"$/) do |number, advocate_name, defendant_name|
  new_advocate = create_advocate_with_full_name(advocate_name, @advocate.provider)
  new_advocate.provider = @advocate.provider
  claims = create_list(:submitted_claim, number.to_i, external_user: new_advocate )
  claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
end

Then(/^I should see my provider's claims$/) do
  provider = Provider.first
  claim_dom_ids = provider.claims.map { |c| "claim_#{c.id}" }
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector("##{dom_id}")
  end

  other_claim_dom_ids = @other_claims.map { |c| "claim_#{c.id}" }
  other_claim_dom_ids.each do |dom_id|
    expect(page).to_not have_selector("##{dom_id}")
  end
end

Then(/^I should see my provider's (\d+) "(.*?)" claims$/) do |number, state|
  provider = Provider.first
  claim_dom_ids = provider.claims.send(state.to_sym).map { |c| "claim_#{c.id}" }

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
  if number == '0'
    expect(page).to have_content('No claims found')
  else
    expect(page).to have_content(/#{number} claims? of #{number} matching "#{name}"/)
  end
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
  advocate = create(:external_user, :advocate)
  advocate.user.first_name = full_name.split.first
  advocate.user.last_name = full_name.split.last
  advocate.user.save!
  advocate
end
