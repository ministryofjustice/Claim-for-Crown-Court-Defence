class ClaimSummaryPage < SitePrism::Page
  set_url "/external_users/claims/{claim_id}/summary"

  element :continue, "div.claim-summary-sidebar > div.claim-summary-hgroup > a:nth-of-type(1)"
end
