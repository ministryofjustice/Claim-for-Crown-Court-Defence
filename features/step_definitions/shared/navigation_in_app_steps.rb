#######
#NAVIGATION

#NOTES: FOR ALL NAVIGATION REQUIREMENTS WITHIN ADP

When(/^I visit that claim's "(.*?)" detail page$/) do |namespace|
  case namespace
    when 'advocate'
      visit advocates_claim_path(@claim)
    when 'case worker'
      visit case_workers_claim_path(@claim)
  end
end

When(/^I visit Manage case workers page/) do
  visit case_workers_admin_case_workers_path
end
