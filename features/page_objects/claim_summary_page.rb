class ClaimSummaryPage < SitePrism::Page
  set_url "/external_users/claims/{claim_id}/summary"

  element :continue, "div.new-claim-sidebar > div.new-claim-hgroup > a:nth-of-type(1)"
end
