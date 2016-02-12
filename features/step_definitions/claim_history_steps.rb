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

Then(/^I should see the state change to allocated reflected in the history$/) do
  @claim.reload
  within '#panel1' do
    history = all('.event').last
    expect(history).to have_content(/Claim allocated/)
  end
end

When(/^I visit the claim's detail page$/) do
  visit external_users_claim_path(@claim)
end
