def case_worker_claims_show_page
  @case_worker_claims_show_page ||= CaseWorkerClaimShowPage.new
end

Given(/^the claim "([^"]*)" has an injection error$/) do |case_number|
  claim = Claim::BaseClaim.find_by(case_number: case_number)
  create(:injection_attempt, :with_errors, claim: claim)
end

Then(/^The injection error summary is visible$/) do
  expect(case_worker_claims_show_page.injection_error_summary).to be_visible
end

Then(/^I click the dismiss injection error button$/) do
  pending
  case_worker_claims_show_page.dimiss_button.click
end

Then(/^the injection error disappears$/) do
  pending
  expect(case_worker_claims_show_page.injection_error_summary).not_to be_visible
end

Then(/^the claim I've just updated no longer has an error in the list$/) do
  pending 'need your claims page object'
end
