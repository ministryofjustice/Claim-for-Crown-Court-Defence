Then('I am on the new user page') do
  expect(@new_user_page).to be_displayed
end

Then('I am on the edit user page') do
  expect(@edit_user_page).to be_displayed
end
