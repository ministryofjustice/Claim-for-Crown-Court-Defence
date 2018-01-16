def case_worker_claims_show_page
  @case_worker_claims_show_page ||= CaseWorkerClaimShowPage.new
end

Given(/^the claim "([^"]*)" has an injection error$/) do |case_number|
  claim = Claim::BaseClaim.find_by(case_number: case_number)
  create(:injection_attempt, :with_errors, claim: claim)
end

Then(/^the injection error summary is visible$/) do
  expect(case_worker_claims_show_page.injection_error_summary).to be_visible
end

# TODO: this step does not work
Then(/^I click the dismiss injection error button$/) do
  case_worker_claims_show_page.injection_error_summary.dismiss_link.click
  wait_for_ajax
end

Then(/^the injection error disappears$/) do
  expect(case_worker_claims_show_page.injection_error_summary).not_to be_displayed
end
