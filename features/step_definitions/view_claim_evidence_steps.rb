
When(/^I visit the detail link for a claim$/) do
  within("#claims-list") do
	  first('a.js-test-case-number-link').click
	end
end

When(/^I visit the view link for a claim$/) do
  visit advocates_root_path
  within('#submitted') do
    within('.claims_table') do
      first(:link, "View").click
    end
  end
end

When(/^I expand the submitted claims accordion and visit the view link for a claim$/) do
  visit advocates_root_path
  find('h2', text: 'Submitted').click
  within('#submitted') do
    within('.claims_table') do
      first(:link, "View").click
    end
  end
end

Then(/^I see links to view\/download each document submitted with the claim$/) do
  available_evidence = page.all(:css, 'div.item-controls')
  expect(available_evidence.count).to_not eq 0
  available_evidence.each do |evidence|
    expect(evidence).to have_link 'View'
    expect(evidence).to have_link 'Download'
  end
end

When(/^click on a link to (download|view) some evidence$/) do |link|
  find('h2', text: 'Evidence list').click
  first('.item-controls').click_link(link.titlecase)
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
