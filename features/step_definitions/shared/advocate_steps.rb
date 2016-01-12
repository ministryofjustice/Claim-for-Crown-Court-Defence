#######
# Advocate

#NOTES: FOR ALL ADVOCATE REQUIREMENTS WITHIN ADP


# Usage:
# Given 1 case worker exists
# Given 12 case workers exist

Given(/^(\d+) advocates? exists?$/) do |quantity|
  @advocates = create_list(:external_user, quantity.to_i)
end
