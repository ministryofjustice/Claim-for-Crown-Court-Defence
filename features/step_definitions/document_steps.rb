When(/^I upload an example document$/) do

  @description = SecureRandom.uuid
  attach_file(:document_document, 'features/examples/shorter_lorem.docx')
  fill_in('Description', with: @description)
  click_on('Upload')
end

Then(/^The example document should exist on the system$/) do
  expect(Document.find_by(description: @description)).to be_present
end

Then(/^I should be told I need to select a claim first$/) do
  expect(page).to have_content('add from a claim')
end
