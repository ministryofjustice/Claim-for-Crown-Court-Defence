Given(/^The API promo feature flag is enabled$/) do
  allow(Settings).to receive(:api_promo_enabled?).and_return(true)
end

And(/^The API promo banner (is|is not) visible$/) do |visibility|
  visible = visibility == 'is'
  expect(page).to have_selector('div.js-callout-banner[data-setting=api_promo_seen]', visible: visible)
end
