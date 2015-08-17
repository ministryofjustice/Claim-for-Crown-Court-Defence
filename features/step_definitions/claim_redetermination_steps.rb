Given(/^I have a (.+) claim$/) do |state|
  @claim = create(state.to_sym, advocate: @advocate)
end

When(/^I visit the claims's detail page$/) do
  visit advocates_claim_path(@claim)
end

Then(/^I should (not )?see a control in the messages section to request a redetermination$/) do |negate|
  if negate.present?
    expect(page).to_not have_selector('#message_request_redetermination')
  else
    expect(page).to have_selector('#message_request_redetermination')
  end
end

When(/^I check "(.*?)" and send a message$/) do |checkbox_text|
  check checkbox_text
  fill_in 'message_subject', with: 'Redetermination request'
  fill_in 'message_body', with: 'lorem ipsum'
  click_button 'Post'
end

Then(/^the claim should be in the redetermination state$/) do
  @claim.reload
  expect(@claim.state).to eq('redetermination')
end

Then(/^a notice should be present in the claim status panel$/) do
  state_transition_date = @claim.claim_state_transitions.last.created_at
  expect(page).to have_content("Opened for redetermination on #{state_transition_date} (see messages/notes for further details).")
end

Given(/^a redetermined claim is assigned to me$/) do
  @claim = create(:redetermination_claim)
  @claim.case_workers << @case_worker
end

Then(/^when I select a state of "(.*?)" and update the claim$/) do |form_state|
  select form_state, from: 'claim_state_for_form'
  click_button 'Update'
end

Then(/^the claim should be in the "(.*?)" state$/) do |state|
  @claim.reload
  expect(@claim.state).to eq(state)
end

Then(/^the claim should no longer be open for redetermination$/) do
  expect(@claim.opened_for_redetermination?).to eq(false)
end
