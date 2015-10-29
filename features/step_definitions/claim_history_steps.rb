Given(/^I have a claim in draft state$/) do
  @claim = create(:claim, advocate: @advocate)
end

Given(/^I submit the claim$/) do
  visit edit_advocates_claim_path(@claim)
  click_on 'Submit to LAA'
end

Then(/^I should see the state change to submitted reflected in the history$/) do
  @claim.reload
  within '#messages' do
    within '.messages-list' do
      history = all('.event').last
      expect(history).to have_content(/Your claim has been submitted/)
    end
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
  within '#messages' do
    within '.messages-list' do
      history = all('.event').last
      expect(history).to have_content(/Claim authorised/)
    end
  end
end

When(/^I visit the claim's detail page$/) do
  visit advocates_claim_path(@claim)
end
