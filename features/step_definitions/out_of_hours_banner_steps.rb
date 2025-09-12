And(/^the out of hours banner (is|is not) visible$/) do |visibility|
  selector = 'div.moj-alert[data-setting=out_of_hours_banner_seen]'

  if visibility == 'is'
    expect(page).to have_selector(selector)
  else
    expect(page).not_to have_selector(selector)
  end
end
