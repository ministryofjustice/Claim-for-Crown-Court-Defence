Given(/^I attempt to sign in with an incorrect password$/) do
  @advocate = create(:advocate, :admin)
  visit new_user_session_path
  sign_in(@advocate.user, 'passwordXXXXX')
end


Given(/^I should be redirected back to the sign in page$/) do
  expect(current_path).to eq '/users/sign_in'
end


Given(/^I should see a sign in error message$/) do
  expect(page).to have_content('Invalid email or password')
end

Given(/^I fill in the claim details omitting the advocate$/) do
  steps <<-STEPS
    Given I fill in the claim details
  STEPS
end


Given(/^I attempt to submit to LAA without specifying all the details$/) do
  steps <<-STEPS
    Given I fill in the claim details
    And I blank out the case number
    And I submit to LAA
  STEPS
end

And(/^I blank out the case number$/) do
  fill_in 'claim_case_number', with: ""
end


Given(/^I should be redirected back to the create claim page$/) do
  expect(current_path).to eq '/advocates/claims'
end


And(/^The entered values should be preserved on the page$/) do
  expected_drop_down_values = {
            'claim_case_type'             => 'Guilty plea',
            'claim_prosecuting_authority' => 'CPS',
            'claim_court_id'              => 'some court',
            'claim_advocate_category'     => 'QC',
            'claim_offence_id'            => "Murder"
          }
  expected_drop_down_values.each do |selector_id, selected_item|
    within('#new_claim') do
      expect(page.has_select?(selector_id, selected: selected_item)).to be true
    end
  end
end


And(/^I should see the error message "(.+)"$/) do | error_message |
  within('.validation-summary') do
    expect(page).to have_content(error_message)
  end
end
