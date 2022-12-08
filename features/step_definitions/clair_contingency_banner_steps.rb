Given(/^The clair contingency banner feature flag is enabled$/) do
  allow(Settings).to receive(:clair_contingency_banner_enabled?).and_return(true)
end

And(/^The clair contingency banner (is|is not) visible$/) do |visibility|
  selector = 'div.js-callout-banner[data-setting=clair_contingency_banner_seen]'

  if visibility == 'is'
    expect(page).to have_selector(selector)
  else
    expect(page).not_to have_selector(selector)
  end
end
