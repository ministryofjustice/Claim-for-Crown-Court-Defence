Given(/^a certified claim has been assigned to me$/) do
  @claim = create(:allocated_claim)
  FactoryGirl.create(:certification, claim: @claim)
  @claim.case_workers << @case_worker
end

Then(/^I should see who certified the claim$/) do
  within ('.certification-info-row') do
    expect(page).to have_content("Reason: #{@claim.certification.certification_type.name}")
  end
end

Then(/^I should see the reason for certification$/) do
  within ('.certification-info-row') do
    expect(page).to have_content("Reason: #{@claim.certification.certification_type.name}")
  end
end
