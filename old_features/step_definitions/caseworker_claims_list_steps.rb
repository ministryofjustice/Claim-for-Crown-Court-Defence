
Given(/^claims have been assigned to me$/) do
  @claims = create_list(:allocated_claim, 5)
  @other_claims = create_list(:allocated_claim, 3)
  @claims.each { |claim| claim.case_workers << @case_worker }
  create :defendant, claim_id: @claims.first.id, representation_orders: [ FactoryBot.create(:representation_order, maat_reference: '7418529635') ]
  create :defendant, claim_id: @claims.second.id, representation_orders: [ FactoryBot.create(:representation_order, maat_reference: '9516249873') ]
end

Given(/^there are allocated claims$/) do
  @claims = FactoryBot.create_list(:allocated_claim, 3)
end

Given(/^there are unallocated claims$/) do
  @claims = FactoryBot.create_list(:submitted_claim, 4)
end

Given(/^there are archived claims$/) do
  @claims =  []
  @claims << FactoryBot.create(:authorised_claim)
  @claims << FactoryBot.create(:part_authorised_claim)
  @claims << FactoryBot.create(:rejected_claim)
  @claims << FactoryBot.create(:refused_claim)

  @other_claims = []
  @other_claims << FactoryBot.create(:authorised_claim)
  @other_claims << FactoryBot.create(:part_authorised_claim)
  @other_claims << FactoryBot.create(:rejected_claim)
  @other_claims << FactoryBot.create(:refused_claim)
end

Given(/^I have archived claims$/) do
  step "there are archived claims"
  @claims.each { |claim| claim.case_workers << @case_worker }
end

Given(/^I have (\d+) "(.*?)" claims involving defendant "(.*?)"$/) do |number,state,defendant_name|
  claims = create_list("#{state}_claim".to_sym, number.to_i)
  claims.each do |claim|
    create(:defendant, claim: claim, first_name: defendant_name.split.first, last_name: defendant_name.split.last)
  end
  @case_worker.claims << claims
end

Given(/^I have been assigned claims with evidence attached$/) do
  @claims.each do |claim|
    claim.documents << create(:document)
  end
end

When(/^I visit my dashboard$/) do
  visit case_workers_claims_path
end

Then(/^I should see the unallocated claims$/) do
 @claims.each do | claim |
    expect(page).to have_selector("tr#claim_#{claim.id}")
  end
end

Then(/^I should see the allocated claims$/) do
 @claims.each do | claim |
    expect(page).to have_selector("tr#claim_#{claim.id}")
  end
end

Then(/^I should see all archived claims$/) do
  @claims.each do | claim |
    expect(find('.report')).to have_link(claim.case_number,
          href: case_workers_claim_path(claim))
  end

  @other_claims.each do | other_claim |
    expect(find('.report')).to have_link(other_claim.case_number,
          href: case_workers_claim_path(other_claim))
  end
end

Then(/^I should see only my claims$/) do
  @claims.each do | claim |
    expect(find('.report')).to have_link(claim.case_number,
          href: case_workers_claim_path(claim))
  end

  @other_claims.each do | other_claim |
    expect(find('.report')).to_not have_link(other_claim.case_number,
          href: case_workers_claim_path(other_claim))
  end
end

Given(/^I am signed in and on the case worker dashboard$/) do
  steps <<-STEPS
    Given I am a signed in case worker
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
  @claims.sort_by(&:last_submitted_at).each do | claim |
    expect(find('.report')).to have_link(claim.case_number,
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

Then(/^I should only see (\d+) claims$/) do |number|
  expect(page).to have_content(/#{number} claims? of #{number} matching/)
end

When(/^I search for a claim by MAAT reference$/) do
  fill_in 'search', with: '7418529635'
  click_button 'Search'
end

Then(/^I should only see claims matching the MAAT reference$/) do
  expect(find('.report')).to have_link(@claims.first.case_number)
end

Then(/^I should see the case workers edit and delete link$/) do
  @case_workers.each do |case_worker|
    expect(page).to have_link('Edit', href: edit_case_workers_admin_case_worker_path(case_worker))
    expect(page).to have_link('Delete', href: case_workers_admin_case_worker_path(case_worker))
  end
end
