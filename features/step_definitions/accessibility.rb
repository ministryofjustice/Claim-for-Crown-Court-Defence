# frozen_string_literal: true

Then('the page should be accessible') do
  steps %(Then the page should be axe clean skipping: region)
end

Then('the page should be accessible skipping {string}') do |ruleId|
  steps %(Then the page should be axe clean skipping: region, #{ruleId})
end

Then('the page should be accessible within {string}') do |selector|
  steps %(Then the page should be axe clean within #{selector})
end
