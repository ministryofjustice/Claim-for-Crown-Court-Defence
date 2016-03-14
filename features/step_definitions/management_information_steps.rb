Given(/^I am on the management information page$/) do
  visit case_workers_admin_management_information_url
end

Then(/^I should have a CSV of the report$/) do
  # expect(page.driver.response.headers['Content-Disposition']).to include("filename=\"all_claims_report.csv\"")
  expect(page.driver.response.headers['Content-Disposition']).to match /filename="management_information_.+\.csv/
end


Given(/^There is a CSV file in the stats directory$/) do
  dirname = Stats::ManagementInformationGenerator::STATS_DIR
  FileUtils.mkdir_p(dirname) unless Dir.exist?(dirname)
  File.open(File.join(dirname, 'management_information_2016_03_02_12_11_10.csv'), 'w') do |fp|
    fp.puts "dummy,csv,file"
  end
end



