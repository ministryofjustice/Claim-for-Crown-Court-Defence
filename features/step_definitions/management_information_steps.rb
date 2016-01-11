Given(/^I am on the management information page$/) do
  visit case_workers_admin_management_information_url
end

# When(/^I click the link to download report$/) do
#   click_on 'Download report'
# end

Then(/^I should have a CSV of the report$/) do
  expect(page.driver.response.headers['Content-Disposition']).to include("filename=\"report.csv\"")
end
