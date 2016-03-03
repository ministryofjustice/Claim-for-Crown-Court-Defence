Given(/^case types are seeded$/) do
  load File.join(Rails.root, 'db', 'seeds', 'case_types.rb')
end

Given(/the following claim case types and conditions/) do | table |
  @expected_result = table.raw
  #Remove the column headings from the sample
  @expected_result.shift
end

When(/^I change the claim case types for (re)?trial$/) do |trial_prefix|
  @actual_result = Array.new
  @expected_result.each_with_index do | case_type, index |
    select2 case_type.first, from: 'claim_case_type_id'
    checkVisible = Array.new

    wait_for_ajax

    trial_field_ids = trial_prefix.blank? ? trial_fields : retrial_fields

    trial_field_ids.each do |id|
      visibleElement = find(:css, "##{id}", :visible => false).visible? ? "should" : "should not"
      checkVisible << visibleElement
    end

    @actual_result << [case_type.first, checkVisible.uniq.join(', ') ]

  end
end

Then(/^the (re)?trial details should be conditionally shown$/) do |trial_prefix|
  expect(@actual_result).to match_array(@expected_result)
end

Given(/^a claims has a case type that conditionally displays fields as:$/) do |table|
  @expected_result = table.raw
  #Remove the column headings from the sample
  @expected_result.shift
end


When(/^I am on the edit page for a draft claim of (re)?trial specific case type$/) do |trial_prefix|
  @actual_result = Array.new
  @expected_result.each_with_index do | case_type, index |
    #Create a draft and navigate to it
    steps <<-STEPS
      When I am on the edit page for a draft claim of case type #{case_type.first}
    STEPS

    checkVisible = Array.new

    wait_for_ajax

    trial_field_ids = trial_prefix.blank? ? trial_fields : retrial_fields

    trial_field_ids.each do |id|
      visibleElement = find(:css, "##{id}", :visible => false).visible? ? "should" : "should not"
      checkVisible << visibleElement
    end

    @actual_result << [case_type.first, checkVisible.uniq.join(', ') ]

  end
end

Given(/^I am on the edit page for a draft claim of case type (.*?)$/) do |case_type|
  case_type = CaseType.find_or_create_by!(name: case_type)
  claim = create(:claim, case_type: case_type, external_user: @advocate)
  visit edit_external_users_claim_path(claim.reload)
end

def trial_fields
  %w(
    claim_first_day_of_trial_dd
    claim_first_day_of_trial_mm
    claim_first_day_of_trial_yyyy
    claim_estimated_trial_length
    claim_actual_trial_length
    claim_trial_concluded_at_dd
    claim_trial_concluded_at_mm
    claim_trial_concluded_at_yyyy
  )
end

def retrial_fields
  %w(
    claim_retrial_started_at_dd
    claim_retrial_started_at_mm
    claim_retrial_started_at_yyyy
    claim_retrial_estimated_length
    claim_retrial_actual_length
    claim_retrial_concluded_at_dd
    claim_retrial_concluded_at_mm
    claim_retrial_concluded_at_yyyy
  )
end
