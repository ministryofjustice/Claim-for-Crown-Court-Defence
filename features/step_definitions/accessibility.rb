# frozen_string_literal: true

Then('the page should be accessible within {string}') do |selector|
  steps %(Then the page should be axe clean within "#{selector}")
end
