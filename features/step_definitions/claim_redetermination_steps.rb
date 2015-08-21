Given(/^I have a (.+) claim$/) do |state|
  @claim = create(state.to_sym, advocate: @advocate)
end

Given(/^the claim has a case worker assigned to it$/) do
  case_worker = create(:case_worker)
  @claim.case_workers << case_worker
end

When(/^I visit the claims's detail page$/) do
  visit advocates_claim_path(@claim)
end

Then(/^I should (not )?see a control in the messages section to request a redetermination$/) do |negate|
  if negate.present?
    expect(page).to_not have_selector('#message_claim_action')
  else
    expect(page).to have_selector('#message_claim_action')
  end
end

When(/^I select "(.*?)" and send a message$/) do |option_text|
  select option_text, from: 'message_claim_action'
  fill_in 'message_subject', with: 'Redetermination request'
  fill_in 'message_body', with: 'lorem ipsum'
  click_button 'Post'
end

Then(/^the claim should no longer have case workers assigned$/) do
  @claim.reload
  expect(@claim.case_workers).to be_empty
end

Then(/^a redetermination notice should be present in the claim status panel$/) do
  state_transition_date = @claim.claim_state_transitions.last.created_at
  expect(page).to have_content("Opened for redetermination on #{state_transition_date} (see messages/notes for further details).")
end

Then(/^a written reasons notice should be present in the claim status panel$/) do
  expect(page).to have_content("Awaiting written reasons.")
end

Given(/^a redetermined claim is assigned to me$/) do
  @claim = create(:redetermination_claim)
  @claim.case_workers << @case_worker
end

Given(/^a written reasons claim is assigned to me$/) do
  @claim = create(:awaiting_written_reasons_claim)
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

Then(/^when I check "(.*?)" and send a message$/) do |checkbox_label_text|
  check checkbox_label_text
  fill_in 'message_subject', with: 'Written reasons attached'
  fill_in 'message_body', with: 'lorem ipsum'
  click_button 'Post'
end

Then(/^the claim should be in the state previous to the written reasons request$/) do
  @claim.reload
  expect(@claim.state).to eq(@claim.claim_state_transitions.order(created_at: :asc)[-3].from)
end

Then(/^the claim should no longer awaiting written reasons$/) do
  @claim.reload
  expect(@claim).to_not be_awaiting_written_reasons
end

Then(/^a form should be visible for me to enter the redetermination amounts$/) do
  expect(page).to have_content('Enter redetermined amounts')
  expect(page).to have_selector('#claim_redeterminations_attributes_0_fees')
end

When(/^I enter redetermination amounts$/) do 
  fill_in 'claim_redeterminations_attributes_0_fees', with: 1577.22
  fill_in 'claim_redeterminations_attributes_0_expenses', with: 805.75
  click_button 'Update'
end


Then(/^There should be no form to enter redetermination amounts$/) do
  expect(page).not_to have_content('Enter redetermined amounts')
  expect(page).not_to have_selector('#claim_redeterminations_attributes_0_fees')
end

Then(/^The redetermination I just entered should be visible$/) do
  expect(page).to have_content('Redetermination of')
  within('#redetermination-fees') do
    expect(page).to have_content('£1,577.22')
  end
  within('#redetermination-expenses') do
    expect(page).to have_content('£805.75')
  end
end
