When('I see the cookies banner') do
  expect(@cookie_page).to have_banner
  expect(@cookie_page.banner).to be_visible
  expect(@cookie_page.banner).to have_content 'Accept analytics cookies'
end

When('I accept the cookies') do
  @cookie_page.banner.message.accept_cookies.click
end

When('I reject the cookies') do
  @cookie_page.banner.message.reject_cookies.click
end

Then('I see the cookie confirmation message') do
  expect(@cookie_page.banner).to be_visible
  expect(@cookie_page.banner).to have_content 'Your cookie settings were saved'
end

Then('I hide the cookie confirmation message') do
  @cookie_page.banner.message.hide.click
end

Then('the cookie banner is not available') do
  expect(@cookie_page).to have_no_banner
end

When('I click to view cookies') do
  @cookie_page.banner.message.view_cookies.click
end

When('I click the accept cookies radio button') do
  @cookie_page.form.accept_cookies.click
end

When('I click the reject cookies radio button') do
  @cookie_page.form.reject_cookies.click
end

When('I save changes to cookies') do
  @cookie_page.form.submit.click
end

Then('the cookie preference is saved') do
  expect(@cookie_page.success_notification).to be_visible
  expect(@cookie_page.success_notification).to have_content 'You’ve set your cookie preferences.'
end
