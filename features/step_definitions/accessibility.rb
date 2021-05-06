# frozen_string_literal: true

Then('the page should be accessible') do
  steps %(Then the page should be axe clean skipping: region, aria-allowed-attr)
end

Then('the page should be accessible within {string}') do |selector|
  steps %(Then the page should be axe clean within "#{selector}")
end
