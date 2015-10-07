Given(/^I trigger a change on a form input$/) do
  script = "$('#claim_case_type_id').trigger('change');"
  page.execute_script(script)
  wait_for_ajax
end

Then(/^(a|no) claim intention should have been created$/) do |option|
  expected_count = option == 'no' ? 0 : 1
  expect(ClaimIntention.count).to eq(expected_count)
end
