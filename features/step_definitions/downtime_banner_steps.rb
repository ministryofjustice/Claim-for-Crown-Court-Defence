Given("the downtime feature flag is enabled") do
  allow(Settings).to receive(:downtime_warning_enabled?).and_return true
end

Given("the downtime date is set to {string}") do |string|
  allow(Settings).to receive(:downtime_warning_date).and_return(string)
end

Then(/^the downtime banner is (not )?displayed$/) do |negate|
  if negate
    expect(page).not_to have_selector(downtime_banner)
  else
    expect(page).to have_selector(downtime_banner)
  end
end

Then("the downtime banner should say {string}") do |string|
  expect(page).to have_selector(downtime_banner, text: string)
end

def downtime_banner
  'div.moj-banner'.freeze
end
