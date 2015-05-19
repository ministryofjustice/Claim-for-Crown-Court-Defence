
When(/^I visit the detailed view for a claim$/) do
  first('div.claim-controls').click_link('Detail')
end

Then(/^I see links to view\/download each document submitted with the claim$/) do
  evidence_list = page.all(:css, '#evidence-list li')
  expect(evidence_list.count).to_not eq 0
  evidence_list.each do |evidence_type|
    expect(evidence_type).to have_link 'View'
    expect(evidence_type).to have_link 'Download'
  end
end

When(/^click on a link to (download|view) some evidence$/) do |link|
  first('.item-controls').click_link(link.titlecase)
end

Then(/^I should get a download with the filename "(.*)"$/) do |filename|
  page.driver.response.headers['Content-Disposition'].should include("filename=\"#{filename}\"")
end

Then(/^I see "longer_lorem.pdf" in my browser$/) do
  expect(page.body).to match(/.*PDF.*/i)
end

Then(/^a new tab opens$/) do
  expect(page.driver.browser.window_handles.count).to eq 2
end
