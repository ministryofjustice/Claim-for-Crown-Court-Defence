def case_worker_claims_show_page
  @case_worker_claims_show_page ||= CaseWorkerClaimShowPage.new
end

def case_worker_your_claims_page
  @case_worker_your_claims_page ||= CaseWorkerYourClaimsPage.new
end

When(/^I select claim "([^"]*)"$/) do |case_number|
  case_worker_your_claims_page.claim_for(case_number).case_number.click
end

Given(/^the claim "([^"]*)" has an injection error$/) do |case_number|
  claim = Claim::BaseClaim.find_by(case_number: case_number)
  create(:injection_attempt, :with_errors, claim: claim)
  expect(claim.injection_attempts.last).to be_active
end

Then(/^the injection error summary is (not )?visible$/) do |negate|
  if negate
    expect(case_worker_claims_show_page).to_not have_injection_error_summary
  else
    expect(case_worker_claims_show_page).to have_injection_error_summary
  end
end

Then(/^there are "([^"]*)" injection error messages$/) do |num|
  expect(case_worker_claims_show_page.injection_error_summary).to have_injection_errors(count: num.to_i)
end

And(/^I dismiss the injection error$/) do
  case_worker_claims_show_page.injection_error_summary.dismiss_link.click
  case_worker_claims_show_page.injection_error_summary.wait_until_header_invisible(10) # uses jQuery slide effect, so takes time
end

Then(/^claim "([^"]*)" does (not )?have an injection error visible$/) do |case_number, negate|
  if negate
    expect(case_worker_your_claims_page.claim_for(case_number)).to_not have_error_message
  else
    expect(case_worker_your_claims_page.claim_for(case_number)).to have_error_message
  end
end
