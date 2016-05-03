require "capybara"
require "capybara/cucumber"
require "selenium-webdriver"
require "site_prism"

Before do
  @external_user_claim_show_page = ExternalUserClaimShowPage.new
  @case_worker_claim_show_page = CaseWorkerClaimShowPage.new
  @claim_form_page = ClaimFormPage.new
  @litigator_claim_form_page = LitigatorClaimFormPage.new
  @claim_summary_page = ClaimSummaryPage.new
  @external_user_home_page = ExternalUserHomePage.new
  @case_worker_home_page = CaseWorkerHomePage.new
  @certification_page = CertificationPage.new
  @confirmation_page = ConfirmationPage.new
  @allocation_page = AllocationPage.new
end
