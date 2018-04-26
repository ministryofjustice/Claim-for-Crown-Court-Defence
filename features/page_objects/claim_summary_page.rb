class ClaimSummaryPage < SitePrism::Page
  set_url "/external_users/claims/{claim_id}/summary"

  element :continue, ".form-buttons > a.button-continue:nth-of-type(1)"
end
