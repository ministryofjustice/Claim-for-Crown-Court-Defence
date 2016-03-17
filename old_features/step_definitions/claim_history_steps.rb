Given(/^I have a claim in draft state$/) do
  @claim = create(:claim, external_user: @advocate)
end

Given(/^I submit the claim$/) do
  visit edit_external_users_claim_path(@claim)
  click_on 'Submit to LAA'
end

Then(/^I should see the state change to submitted reflected in the history$/) do
  @claim.reload

  within '#panel1' do
    history = all('.event').last
    expect(history).to have_content(/Your claim has been submitted/)
  end
end

When(/^I visit the claim's case worker detail page$/) do
  visit case_workers_claim_path(@claim)
end

Given(/^I have been allocated a claim$/) do
  @claim = create(:allocated_claim)
  @case_worker.claims << @claim
end

When(/^I mark the claim authorised$/) do
  choose 'Authorised'
  fill_in 'claim_assessment_attributes_fees', with: '100.00'
  click_on 'Update'
end

Then(/^I should see the state change to authorised reflected in the history$/) do
  @claim.reload
  within '#panel1' do
    history = all('.event').last
    expect(history).to have_content(/Claim authorised/)
  end
end

When(/^I visit the claim's detail page$/) do
  visit external_users_claim_path(@claim)
end

Then(/^the messages section should be expanded$/) do
  expect(find(:css, '#panel1')).to be_visible
end
