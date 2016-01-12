Given(/^case types are seeded$/) do
  load File.join(Rails.root, 'db', 'seeds', 'case_types.rb')
end

Then(/^I should( not)? see the trial detail fields$/) do |negation|
  does = negation.nil? ? 'to' : negation.gsub(/\s+/,'').downcase == 'not' ? 'to_not' : 'to'

  trial_field_ids = %w(
    claim_first_day_of_trial_dd
    claim_first_day_of_trial_mm
    claim_first_day_of_trial_yyyy
    claim_estimated_trial_length
    claim_actual_trial_length
    claim_trial_concluded_at_dd
    claim_trial_concluded_at_mm
    claim_trial_concluded_at_yyyy
  )

  trial_field_ids.each do |id|
    expect(page).method(does).call have_selector("##{id}")
  end
end

Given(/^I am on the edit page for a draft claim of case type "(.*?)"$/) do |case_type|
  case_type = CaseType.find_or_create_by!(name: case_type)
  claim = create(:claim, case_type: case_type, external_user: @advocate)
  visit edit_external_users_claim_path(claim.reload)
end
