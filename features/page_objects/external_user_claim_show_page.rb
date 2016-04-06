require_relative "claim_show_page"

class ExternalUserClaimShowPage < ClaimShowPage
  set_url "/external_users/claims{/claim_id}"
end
