require_relative "claim_show_page"

class CaseWorkerClaimShowPage < ClaimShowPage
  set_url "/case_workers/claims{/claim_id}"
end
