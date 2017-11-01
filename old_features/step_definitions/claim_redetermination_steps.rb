Given(/^I have a (.+) claim$/) do |state|
  @claim = create(state.to_sym, external_user: @advocate)
end

Given(/^the claim has a case worker assigned to it$/) do
  case_worker = create(:case_worker)
  @claim.case_workers << case_worker
end

Then(/^I should (not )?see a control in the messages section to request a redetermination$/) do |negate|
  if negate.present?
    expect(page).to_not have_selector('.js-test-claim-action')
  else
    expect(page).to have_selector('.js-test-claim-action')
  end
end

When(/^I select "(.*?)" and send a message$/) do |option_text|
  choose option_text
  fill_in 'message_body', with: 'lorem ipsum'
  click_button 'Send'
end

Then(/^the claim should no longer have case workers assigned$/) do
  @claim.reload
  expect(@claim.case_workers).to be_empty
end

Then(/^a redetermination notice should be present in the claim status panel$/) do
  state_transition_date = @claim.last_state_transition.created_at
  expect(page).to have_content("Opened for redetermination on #{state_transition_date} (see messages for further details).")
end

Then(/^a written reasons notice should be present in the claim status panel$/) do
  expect(page).to have_content("Awaiting written reasons.")
end

Given(/^a redetermined claim is assigned to me$/) do
  @claim = create(:redetermination_claim)
  @claim.fees << build(:misc_fee, :with_date_attended, claim: @claim)
  @claim.expenses << build(:expense, :with_date_attended, claim: @claim, expense_type: FactoryBot.build(:expense_type))
  @claim.case_workers << @case_worker
end

Given(/^a written reasons claim is assigned to me$/) do
  @claim = create(:awaiting_written_reasons_claim)
  @claim.case_workers << @case_worker
end

When(/^I select a state of "(.*?)" and update the claim$/) do |form_state|
  choose form_state
  click_button 'Update'
end

Then(/^only the allowed status updates should be offered$/) do
  allowed_updates = ['Part authorised', 'Authorised', 'Refused']
  disallowed_updates = ['Rejected']

  allowed_updates.each do |allowed_update|
    within('.edit_claim') { expect(page).to have_content allowed_update }
  end

  disallowed_updates.each do |disallowed_update|
    within('.edit_claim') { expect(page).to_not have_content disallowed_update }
  end

end

Then(/^the claim should no longer be open for redetermination$/) do
  expect(@claim.opened_for_redetermination?).to eq(false)
end

Then(/^when I check "(.*?)" and send a message$/) do |checkbox_label_text|
  check checkbox_label_text
  fill_in 'message_body', with: 'lorem ipsum'
  click_button 'Send'
end

Then(/^the claim should be in the state previous to the written reasons request$/) do
  @claim.reload
  expect(@claim.state).to eq(@claim.claim_state_transitions[2].from)
end

Then(/^the claim should no longer awaiting written reasons$/) do
  @claim.reload
  expect(@claim).to_not be_awaiting_written_reasons
end

Then(/^a form should be visible for me to enter the redetermination amounts$/) do
  expect(page).to have_selector('#claim_redeterminations_attributes_0_fees')
end

When(/^I enter redetermination amounts$/) do
  fill_in 'claim_redeterminations_attributes_0_fees', with: 1577.22
  fill_in 'claim_redeterminations_attributes_0_expenses', with: 805.75
  choose 'Part authorised'
  click_button 'Update'
end

Then(/^There should be no form to enter redetermination amounts$/) do
  expect(page).not_to have_selector('#claim_redeterminations_attributes_0_fees')
end

Then(/^The redetermination I just entered should be visible$/) do
  within('#determination-fees') do
    expect(page).to have_content('£1,577.22')
  end
  within('#determination-expenses') do
    expect(page).to have_content('£805.75')
  end
end

Then(/^I should see a claim marked as a redetermination$/) do
  within('.report') do
    expect(find(:xpath, './tbody')).to have_content("(redetermination)")
  end
end
