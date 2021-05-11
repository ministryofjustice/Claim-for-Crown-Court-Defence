Then('I am on the new user sign up page') do
  expect(@new_user_sign_up_page).to be_displayed
end

Then('I am on the software vendor terms and conditions page') do
  expect(@vendor_tandcs_page).to be_displayed
end
