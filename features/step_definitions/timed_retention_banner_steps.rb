And(/^The timed retention banner (is|is not) visible$/) do |visibility|
  selector = 'div.js-callout-banner[data-setting=timed_retention_banner_seen]'

  if visibility == 'is'
    expect(page).to have_selector(selector)
  else
    expect(page).not_to have_selector(selector)
  end
end
