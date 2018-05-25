When(/^I send a message '(.*?)'$/) do |text|
  @case_worker_claim_show_page.messages_panel.enter_your_message.set text
  @case_worker_claim_show_page.messages_panel.send.click
end

Then(/^the claim should be displayed with a status of 'Allocated'$/) do
  claim = @external_user_home_page.claim_for(@claim.case_number)
  expect(claim.state.text).to eq("Allocated")
end

Then(/^it is displaying '(.*?)' in the messages column$/) do |text|
  claim = @external_user_home_page.claim_for(@claim.case_number)
  expect(claim.view_messages.text).to eq(text)
end

When(/^I open up the claim$/) do
  @external_user_home_page.claim_for(@claim.case_number).case_number.click
end

Then(/^the message '(.*?)' from the caseworker should be visible$/) do |text|
  expect(@external_user_claim_show_page).to have_content(text)
end

Then(/^the (last|first|second|third|fourth|fifth) message contains '(.*?)'$/) do |method, text|
  expect(@external_user_claim_show_page.messages_panel.messages.send(method.to_sym)).to have_text(text)
end

Then(/^the messages should not contain '(.*?)'$/) do |text|
  expect(@external_user_claim_show_page.messages_panel.messages.map(&:text).join).to_not have_text(text)
end

When(/^I enter a message '(.*?)'$/) do |text|
  @message = text
  @external_user_claim_show_page.messages_panel.enter_your_message.set @message
end

When(/^I upload a file$/) do
  available_docs = Dir.glob "spec/fixtures/files/*.pdf"
  @uploaded_file_path = available_docs.first
  @external_user_claim_show_page.messages_panel.upload_file(@uploaded_file_path)
end

When(/^I click send$/) do
  @external_user_claim_show_page.messages_panel.send.click
end

Then(/^the claim should be visible with 1 new message$/) do
  claim = @case_worker_home_page.claim_for(@claim.case_number)
  expect(claim.view_messages.text).to eq("View (1 new)")
end

When(/^I open the claim$/) do
  @case_worker_home_page.claim_for(@claim.case_number).case_number.click
end

Then(/^the response and uploaded file should be visible$/) do
  expect(@case_worker_claim_show_page.messages_panel).to have_content(@message)
  expect(@case_worker_claim_show_page.messages_panel).to have_content(File.basename(@uploaded_file_path))
end
