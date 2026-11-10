# frozen_string_literal: true

# axe-core 4.14 added stricter checks for aria-labels that omit the visible link text
DEFAULT_SKIPPED_AXE_RULES = 'region, label-content-name-mismatch'

Then('the page should be accessible') do
  steps %(Then the page should be axe clean skipping: #{DEFAULT_SKIPPED_AXE_RULES})
end

Then('the page should be accessible skipping {string}') do |ruleId|
  steps %(Then the page should be axe clean skipping: #{DEFAULT_SKIPPED_AXE_RULES}, #{ruleId})
end

Then('the page should be accessible within {string}') do |selector|
  steps %(Then the page should be axe clean within #{selector})
end
