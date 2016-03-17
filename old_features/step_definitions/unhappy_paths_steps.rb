Given(/^I attempt to sign in with an incorrect password$/) do
  @advocate = create(:external_user, :admin)
  visit new_user_session_path
  sign_in(@advocate.user, 'passwordXXXXX')
end


Given(/^I should be redirected back to the sign in page$/) do
  expect(current_path).to eq '/users/sign_in'
end


Given(/^I should see a sign in error message$/) do
  expect(page).to have_content('Invalid email or password')
end


Given(/^I attempt to submit to LAA without specifying the case number$/) do
  steps <<-STEPS
    Given I fill in the claim details
    And I blank out the case number
    And I submit to LAA
  STEPS
end


Given(/^I attempt to submit to LAA without specifying defendant details$/) do
  steps <<-STEPS
    Given I fill in the claim details
    And I blank out the defendant details
    And I submit to LAA
  STEPS
end

And(/^I blank out the defendant details$/) do
 within '.defendants' do
    fill_in 'claim_defendants_attributes_0_first_name', with: ''
    fill_in 'claim_defendants_attributes_0_last_name', with: ''

    fill_in 'claim_defendants_attributes_0_date_of_birth_dd', with: ''
    fill_in 'claim_defendants_attributes_0_date_of_birth_mm', with: ''
    fill_in 'claim_defendants_attributes_0_date_of_birth_yyyy', with: ''
  end
end

And(/^I blank out the "(.*)" field$/) do |field_id|
  fill_in field_id, with: ""
end

Given(/^I should be redirected back to the create claim page$/) do
  expect(current_path).to eq '/external_users/claims'
end

And(/^The entered values should be preserved on the page$/) do
  murder_offence_id = Offence.find_by(description: 'Murder').id
  expect(page).to have_selector("input[value='#{murder_offence_id}']")


  expect(find(:css,'#claim_advocate_category_qc')).to be_checked

  expected_drop_down_values = {
            'claim_case_type_id'          => 'Guilty plea',
            'claim_court_id'              => 'some court',
          }
  expected_drop_down_values.each do |selector_id, selected_item|
    within('#new_claim') do
      expect(page.has_select?(selector_id, selected: selected_item)).to be true
    end
  end

end



And(/^I should see a summary error message "(.+)"$/) do | error_message |
  within('.error-summary') do
    expect(page).to have_content(error_message)
  end
end

Then(/^I should see a field level error message "(.*?)"$/) do |error_message|
  expect(page).to have_content(error_message)
end
