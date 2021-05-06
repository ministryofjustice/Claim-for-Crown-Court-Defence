Then('I am on the manage users page') do
  expect(@manage_users_page).to be_displayed
end

Then('the following user details should exist:') do |table|
  expect(@manage_users_page).to be_displayed
  table.hashes.each do |row|
    row.each do |data_label, text|
      actual_text_values = @manage_users_page.all("td[data-label='#{data_label}']").map(&:text)
      expect(actual_text_values).to include(text)
    end
  end
end
