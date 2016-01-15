Given(/^I am on the management information page$/) do
  visit case_workers_admin_management_information_url
end

Then(/^I should have a CSV of the report$/) do
  expect(page.driver.response.headers['Content-Disposition']).to include("filename=\"all_claims_report.csv\"")
end
