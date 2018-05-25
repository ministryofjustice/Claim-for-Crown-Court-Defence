Given(/^there is a claim allocated to the case worker with case number '(.*?)'$/) do |case_number|
  # TODO: this does not create a valid submitted claim
  # creates some sort of claim with some information that happens
  # to be in the submitted state
  # To go around this I'm preserving old functionality for the factory by
  # setting the form_step.
  # Going forward this should be properly fixed with an actual factory that is valid
  # for a submitted claim
  @claim = create(:allocated_claim, external_user: @advocate, case_number: case_number, form_step: :case_details)
  @case_worker.claims << @claim
end

Given(/^there is a redetermination claim allocated to the case worker with case number '(.*?)'$/) do |case_number|
  @claim = create(:redetermination_claim, external_user: @advocate, case_number: case_number)
  @case_worker.claims << @claim
end

When(/^I select the claim$/) do
  @case_worker_home_page.claim_for(@claim.case_number).case_number.click
end

When(/^expand the messages section$/) do
  @case_worker_claim_show_page.messages_tab.click
end

When(/^fill out the Fees Total authorised by Laa with the amount of fees claimed$/) do
  @case_worker_claim_show_page.fees.set "1.23"
end

When(/^do the same with expenses$/) do
  @case_worker_claim_show_page.expenses.set "2.34"
end

When(/^I click the authorised radio button$/) do
  @case_worker_claim_show_page.authorised.click
end

# TODO: to be removed once reject refuse feature release accepted
When(/^the reject refuse messaging feature is released$/) do
  allow(Settings).to receive(:reject_refuse_messaging_released_at).and_return(Time.current - 1.day)
end

When(/^I click the rejected radio button$/) do
    @case_worker_claim_show_page.rejected.click
end

And(/^I select the first rejection reason$/) do
  @case_worker_claim_show_page.rejection_reasons.first_reason.click
end

When(/^I click the refused radio button$/) do
  @case_worker_claim_show_page.refused.click
end

And(/^I select the first refusal reason$/) do
  @case_worker_claim_show_page.refusal_reasons.first_reason.click
end

When(/^I click update$/) do
  @case_worker_claim_show_page.update.click
end

Then(/^the status at top of page should be (.*)$/) do |text|
  expect(@case_worker_claim_show_page.status.text).to eq(text)
end

Then(/^the claim I've just updated is no longer in the list$/) do
  expect(@case_worker_home_page).not_to have_content(@claim.case_number)
end
