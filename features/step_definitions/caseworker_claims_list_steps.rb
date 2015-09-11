
Given(/^claims have been assigned to me$/) do
  case_worker = CaseWorker.first
  @claims = create_list(:allocated_claim, 5)
  @other_claims = create_list(:allocated_claim, 3)
  @claims.each_with_index { |claim, index| claim.update_column(:total, index + 1) }
  @claims.each { |claim| claim.case_workers << case_worker }
  create :defendant, claim_id: @claims.first.id, representation_orders: [ FactoryGirl.create(:representation_order, maat_reference: 'AA1245') ]
  create :defendant, claim_id: @claims.second.id, representation_orders: [ FactoryGirl.create(:representation_order, maat_reference: 'BB1245') ]
end

Given(/^there are allocated claims$/) do
  @claims = create_list(:allocated_claim, 5)
end

Given(/^there are unallocated claims$/) do
  @claims = create_list(:submitted_claim, 5)
end

Given(/^there are completed claims$/) do
  @claims = create_list(:completed_claim, 5)
end

# TODO update once "Archive" has been created and working
#Then(/^I should see the allocated claims$/) do
#  click_on "Allocated claims (#{@claims.count})"
#  expect(page).to have_content("Allocated claims (#{@claims.count})")
#end

# TODO update once "Archive" has been created and working
#Then(/^I should see the unallocated claims$/) do
#  click_on "Unallocated claims (#{@claims.count})"
#  expect(page).to have_content("Unallocated claims (#{@claims.count})")
#end

Then(/^I should see the completed claims$/) do
  click_on "Completed claims (#{@claims.count})"
  expect(page).to have_content("Completed claims (#{@claims.count})")
end

Given(/^I have (\d+) "(.*?)" claims involving defendant "(.*?)"$/) do |number,state,defendant_name|
  claims = create_list("#{state}_claim".to_sym, number.to_i)
  claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
  @case_worker.claims << claims
end

Given(/^I have been assigned claims with evidence attached$/) do
  claim = @claims.first
  claim.documents << create(:document)
end

When(/^I visit my dashboard$/) do
  visit case_workers_claims_path
end

Then(/^I should see only my claims$/) do
  @claims.each do | claim |
    expect(find('#claims-list')).to have_link(claim.case_number,
          href: case_workers_claim_path(claim))
  end

  @other_claims.each do | other_claim |
    expect(find('#claims-list')).to_not have_link(other_claim.case_number,
          href: case_workers_claim_path(other_claim))
  end
end

Given(/^I am signed in and on the case worker dashboard$/) do
  steps <<-STEPS
    Given I am a signed in case worker
      And There are fee schemes in place
      And claims have been assigned to me
     When I visit my dashboard
     Then I should see only my claims
      And I should see the claims sorted by oldest first
  STEPS
end

When(/^I sort the claims by oldest first$/) do
  click_on 'Oldest'
end

Then(/^I should see the claims sorted by oldest first$/) do
  @claims.sort_by(&:submitted_at).each do | claim |
    expect(find('#claims-list')).to have_link(claim.case_number,
          href: case_workers_claim_path(claim))
  end
end

#TODO Reintroduce when sorting columns is implemented
#When(/^I sort the claims by highest value first$/) do
#  click_on 'Value - Highest first'
#end

#TODO Reintroduce when sorting columns is implemented
#Then(/^I should see the claims sorted by highest value first$/) do
#  claim_dom_ids = @claims.sort_by(&:total).reverse.map { |c| "claim_#{c.id}" }
#  expect(page.body).to match(/.*#{claim_dom_ids.join('.*')}.*/m)
#end

#TODO Reintroduce when sorting columns is implemented
#When(/^I sort the claims by lowest value first$/) do
#  click_on 'Value - Lowest first'
#end

#TODO Reintroduce when sorting columns is implemented
#Then(/^I should see the claims sorted by lowest value first$/) do
#  claim_dom_ids = @claims.sort_by(&:total).map { |c| "claim_#{c.id}" }
#  expect(page.body).to match(/.*#{claim_dom_ids.join('.*')}.*/m)
#end

When(/^I search claims by defendant name "(.*?)"$/) do |defendant_name|
  fill_in 'search', with: defendant_name
  click_button 'Search'
end

Then(/^I should only see (\d+) "(.*?)" claims$/) do |number, state_name|
  expect(page).to have_content(/#{number} claim?s matching/)
end

When(/^I search for a claim by MAAT reference$/) do
  fill_in 'search', with: 'AA1245'
  click_button 'Search'
end

Then(/^I should only see claims matching the MAAT reference$/) do
    expect(find('#claims-list')).to have_link(@claims.first.case_number)
end

Given(/^I have completed claims$/) do
  case_worker = CaseWorker.first
  @claims = create_list(:completed_claim, 5)
  @other_claims = create_list(:completed_claim, 3)
  @claims.each_with_index { |claim, index| claim.update_column(:total, index + 1) }
  @claims.each { |claim| claim.case_workers << case_worker }

  create :defendant, claim_id: @claims.first.id, representation_orders: [ FactoryGirl.create(:representation_order, maat_reference: 'AA1245') ]
  create :defendant, claim_id: @claims.second.id, representation_orders: [ FactoryGirl.create(:representation_order, maat_reference: 'BB1245') ]
end

# TODO update once "Archive" has been created and working
#When(/^I click on the Completed Claims tab$/) do
#  click_on 'Completed claims'
#end
