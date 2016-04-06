Then(/^I select2 "([^"]*)" from "([^"]*)"$/) do |value, select_id|
  select2 value, from: select_id
end
