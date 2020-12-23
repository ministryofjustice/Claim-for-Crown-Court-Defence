Given(/^The hardship claims banner feature flag is enabled$/) do
  allow(Settings).to receive(:hardship_claims_banner_enabled?).and_return(true)
end

And(/^The hardship claims banner (is|is not) visible$/) do |visibility|
  selector = 'div.js-callout-banner[data-setting=hardship_claims_banner_seen]'

  if visibility == 'is'
    expect(page).to have_selector(selector)
  else
    expect(page).not_to have_selector(selector)
  end
end
