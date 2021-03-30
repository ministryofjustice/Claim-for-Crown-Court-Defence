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

When('I choose {string} cookies') do |option|
  choose("#{option} cookies that measure my website use")
end

Then('the cookie preference is saved') do
  expect(find('.govuk-notification-banner--success').visible?).to eq true
  expect(page).to have_content 'You’ve set your cookie preferences.'
end
