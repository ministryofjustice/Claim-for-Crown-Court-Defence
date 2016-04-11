
When(/^I visit the detail link for a claim$/) do
  within(".report") do
	  first('a.js-test-case-number-link').click
	end
end

When(/^I view the claim$/) do
  visit external_users_root_path
  first('a.js-test-case-number-link').click
end



Then(/^I see links to view\/download each document submitted with the claim$/) do
  available_evidence = page.all(:css, '#download-files-report tbody tr')
  expect(available_evidence.count).to_not eq 0
  available_evidence.each do |evidence|
    expect(evidence).to have_link 'View'
    expect(evidence).to have_link 'Download'
  end
end

When(/^click on a link to (download|view) some evidence$/) do |link|
  find('h2', text: 'Evidence').click
  within('#download-files-report tbody') do
    first('tr').click_link(link.titlecase)
  end
end

Then(/^I should get a download with the filename "(.*)"$/) do |filename|
  expect(page.driver.response.headers['Content-Disposition']).to include("filename=\"#{filename}\"")
end

Then(/^I see "(.*)" in my browser$/) do |filename|
  expect(page.driver.response.headers['Content-Disposition']).to include("inline; filename=\"#{filename}\"")
end

Then(/^a new tab opens$/) do
  expect(page.driver.browser.window_handles.count).to eq 2
end
