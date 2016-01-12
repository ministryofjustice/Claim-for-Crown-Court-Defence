When(/^I visit the advocate archive$/) do
  visit archived_external_users_claims_path
end

Then(/^I should not see non\-archived claims listed$/) do
  Claims::StateMachine.dashboard_displayable_states.each do |state|
    expect(page).not_to have_selector("tr.#{state}")
  end
end