When('I see the cookies banner') do
  expect(page).to have_css '.govuk-cookie-banner'
  expect(page.find('.govuk-cookie-banner').visible?).to eq true
  expect(page).to have_content I18n.t('layouts.cookie_banner.accept_button')
end

Then('I see the {string} confirmation message') do |string|
  expect(find('.govuk-cookie-banner__confirmation').visible?).to eq true
  expect(find('.govuk-cookie-banner__confirmation')).to have_content 'Your cookie settings were saved'
end

Then('the cookie banner is not available') do
  expect(page).not_to have_selector('.govuk-cookie-banner')
end
