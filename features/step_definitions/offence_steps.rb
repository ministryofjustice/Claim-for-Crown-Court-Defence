
# AGFS 9/LGFS only
Then(/^the offence class list is set to '(.*?)'$/) do |text|
  expect(page).to have_xpath("//option[text()='#{text}']")
end

# AGFS 9/LGFS only
Then(/^the offence class list has (.*?) options$/) do |count|
  expect(page).to have_xpath('//select[@id="claim-offence-class-field"]/option', count: count)
end

# AGFS 10 only
When(/^I search for the scheme 10 offence '(.*?)'$/) do |search_text|
  @claim_form_page.offence_search.set search_text
end

# AGFS 11+ only
When(/^I search for a post agfs reform offence '(.*?)'$/) do |search_text|
  @claim_form_page.offence_search.set search_text
end

# AGFS 10/11 only
Then(/^I select the first search result$/) do
  using_wait_time 1 do
    find(:xpath, '//*[@id="offence-list"]/div[3]/div').hover
    find(:xpath, '//*[@id="offence-list"]/div[3]/div/div[2]/a').click
  end
  wait_for_ajax
end

Then('I should see the selected offence {string}') do |offence|
  expect(page).to have_selector('.selected-offence')
  within '.selected-offence' do
    expect(page).to have_content(offence)
  end
end

Then('I should see no selected offence') do
  expect(page).to_not have_selector('div.selected-offence')
end
