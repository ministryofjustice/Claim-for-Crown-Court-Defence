# frozen_string_literal: true

When('I visit the manage users page') do
  @external_user_manage_users_page.load
end

Then('I am on the manage users page') do
  expect(@external_user_manage_users_page).to be_displayed
end

And('I click the link {string} for user {string} on the manage users page') do |label, email|
  row = @external_user_manage_users_page.user_table.rows.find {|row| row.text.include?(email) }
  expect(row).not_to be_nil, "Could not find row containing email '#{email}'"
  row.find_link(label).click
end

Then('the following user details are displayed:') do |table|
  expect(@external_user_manage_users_page).to be_displayed
  table.hashes.each do |row|
    row.each do |data_label, text|
      actual_text_values = @external_user_manage_users_page.all('td').map(&:text)
      expect(actual_text_values).to include(text)
    end
  end
end
