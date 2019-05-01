class ClaimSummaryPage < BasePage
  set_url "/external_users/claims/{claim_id}/summary"

  element :continue, ".form-buttons > a.button:nth-of-type(1)"
  element :change_case_details, "#case-details-section a.link-change:nth-of-type(1)"
  element :change_defendants, "#defendants-section a.link-change:nth-of-type(1)"
  element :change_expenses, "#expenses-section a.link-change:nth-of-type(1)"
end
