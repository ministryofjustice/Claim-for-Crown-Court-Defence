When('I see the cookies banner') do
  expect(page).to have_css '.govuk-cookie-banner'
  expect(page.find('.govuk-cookie-banner').visible?).to eq true
end

Then('I see the {string} confirmation message') do |string|
  expect(page.find('.govuk-cookie-banner__confirmation').visible?).to eq true
  expect(page.find('.govuk-cookie-banner').visible?).to eq false
  expect(page.find('.govuk-cookie-banner__confirmation')).to have_content string
end

Then('the cookie banner is hidden') do
  expect(page.find('.govuk-cookie-banner').visible?).to eq false
end
