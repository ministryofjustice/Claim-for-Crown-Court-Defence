Given(/^a certified claim has been assigned to me$/) do
  @claim = create(:allocated_claim)
  @claim.certification.destroy unless @claim.certification.nil?
  certification_type = FactoryBot.create(:certification_type, name: 'which ever reason i please')
  FactoryBot.create(:certification, claim: @claim, certified_by: 'Bobby Legrand', certification_type: certification_type)
  @case_worker.claims << @claim
  @claim.reload
end

When(/^I visit the case worker claim's detail page$/) do
  visit case_workers_claim_path(@claim)
end

Then(/^I should see who certified the claim$/) do
  within ('.certification-info-row') do
    expect(page).to have_content('Certified by: Bobby Legrand')
  end
end

Then(/^I should see the reason for certification$/) do
  within ('.certification-info-row') do
    expect(page).to have_content("Reason: #{@claim.certification.certification_type.name}")
  end
end

Given(/^a (re)?trial claim has been assigned to me$/) do |trial_prefix|
  @claim = create(:submitted_claim, case_type: FactoryBot.create(:case_type, "#{trial_prefix}trial".to_sym))
  @case_worker.claims << @claim
end

Then(/^I should see (re)?trial details$/) do |trial_prefix|
  expect(page).to have_content("First day of #{trial_prefix}trial")
  if trial_prefix
    expect(page).to have_content("First day of trial")
  end
end
