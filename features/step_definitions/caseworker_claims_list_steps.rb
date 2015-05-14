Given(/^I am a signed in case worker$/) do
  case_worker = create(:case_worker)
  visit new_user_session_path
  sign_in(case_worker.user, 'password')
end

Given(/^claims have been assigned to me$/) do
  case_worker = CaseWorker.first
  @claims = create_list(:submitted_claim, 5)
  @other_claims = create_list(:submitted_claim, 3)
  @claims.each_with_index { |claim, index| claim.update_column(:total, index + 1) }
  @claims.each { |claim| claim.case_workers << case_worker }
  create(:defendant, maat_reference: 'AA1245', claim_id: @claims.first.id)
  create(:defendant, maat_reference: 'BB1245', claim_id: @claims.second.id)
end

Given(/^I have been assigned claims with evidence attached$/) do
    DocumentType.find_or_create_by(description: 'The front sheet(s) from the commital bundle')
    file = File.open('./features/examples/shorter_lorem.docx')
    claim = @claims.first
    claim.documents << Document.create!(claim_id: claim.id, document: file, document_content_type: 'application/msword', document_type_id: DocumentType.first.id)
end

When(/^I visit my dashboard$/) do
  visit case_workers_claims_path
end

Then(/^I should see only my claims$/) do
  claim_dom_ids = @claims.map { |c| "claim_#{c.id}" }
  claim_dom_ids.each do |dom_id|
    expect(page).to have_selector("##{dom_id}")
  end

  other_claim_dom_ids = @other_claims.map { |c| "claim_#{c.id}" }
  other_claim_dom_ids.each do |dom_id|
    expect(page).to_not have_selector("##{dom_id}")
  end
end

Then(/^the claims should be sorted by oldest first$/) do
  claim_dom_ids = @claims.sort_by(&:submitted_at).map { |c| "claim_#{c.id}" }
  expect(page.body).to match(/.*#{claim_dom_ids.join('.*')}.*/m)
end

Given(/^I am signed in and on the case worker dashboard$/) do
  steps <<-STEPS
    Given I am a signed in case worker
      And claims have been assigned to me
     When I visit my dashboard
     Then I should see only my claims
      And the claims should be sorted by oldest first
  STEPS
end

When(/^I sort the the claims by newest first$/) do
  click_on 'Newest'
end

Then(/^I should see the claims sorted by newest first$/) do
  claim_dom_ids = @claims.sort_by(&:submitted_at).reverse.map { |c| "claim_#{c.id}" }
  expect(page.body).to match(/.*#{claim_dom_ids.join('.*')}.*/m)
end

When(/^I sort the the claims by highest value first$/) do
  click_on 'Value - Highest first'
end

Then(/^I should see the claims sorted by highest value first$/) do
  claim_dom_ids = @claims.sort_by(&:total).reverse.map { |c| "claim_#{c.id}" }
  expect(page.body).to match(/.*#{claim_dom_ids.join('.*')}.*/m)
end

When(/^I sort the the claims by lowest value first$/) do
  click_on 'Value - Lowest first'
end

Then(/^I should see the claims sorted by lowest value first$/) do
  claim_dom_ids = @claims.sort_by(&:total).map { |c| "claim_#{c.id}" }
  expect(page.body).to match(/.*#{claim_dom_ids.join('.*')}.*/m)
end

Then(/^I should see the claims count$/) do
  expect(page).to have_content("Current claims (#{@claims.size})")
end

When(/^I search for a claim by MAAT reference$/) do
  fill_in 'search', with: 'AA1245'
  click_button 'Search'
end

Then(/^I should only see claims matching the MAAT reference$/) do
  expect(page).to have_content("Current claims (1)")
  expect(page).to have_selector("#claim_#{@claims.first.id}")
end

Given(/^I have completed claims$/) do
  case_worker = CaseWorker.first
  @claims = create_list(:completed_claim, 5)
  @other_claims = create_list(:completed_claim, 3)
  @claims.each_with_index { |claim, index| claim.update_column(:total, index + 1) }
  @claims.each { |claim| claim.case_workers << case_worker }
  create(:defendant, maat_reference: 'AA1245', claim_id: @claims.first.id)
  create(:defendant, maat_reference: 'BB1245', claim_id: @claims.second.id)
end

When(/^I click on the Completed Claims tab$/) do
  click_on 'Completed claims'
end
