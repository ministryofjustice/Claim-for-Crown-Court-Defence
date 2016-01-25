Given(/^a certified claim has been assigned to me$/) do
  @claim = create(:allocated_claim)
  @claim.certification.destroy
  certification_type = FactoryGirl.create(:certification_type, name: 'which ever reason i please')
  FactoryGirl.create(:certification, claim: @claim, certified_by: 'Bobby Legrand', certification_type: certification_type)
  @claim.case_workers << @case_worker
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
