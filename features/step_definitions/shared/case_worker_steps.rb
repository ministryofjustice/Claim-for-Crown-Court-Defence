#######
# CASE WORKERS

#NOTES: FOR ALL CASE WORKER REQUIREMENTS WITHIN ADP


# Usage:
# Given 1 case worker exists
# Given 12 case workers exist

Given(/^(\d+) case workers? exists?$/) do |quantity|
  @case_workers = create_list(:case_worker, quantity.to_i)
end
