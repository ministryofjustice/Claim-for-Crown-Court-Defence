require_relative "claim_show_page"
require_relative "sections/injection_error_summary_section"

class CaseWorkerClaimShowPage < ClaimShowPage
  set_url "/case_workers/claims{/claim_id}"

  section :injection_error_summary, InjectionErrorSummarySection, 'div.error-summary'
end
