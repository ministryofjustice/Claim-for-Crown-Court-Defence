Given(/^document types exist$/) do
  create(:document_type, description: 'Other')
end

When(/^I upload an example document "longer_lorem.pdf"$/) do
  @notes = SecureRandom.uuid
  select 'Other', from: 'document_document_type_id'
  attach_file(:document_document, 'features/examples/longer_lorem.pdf')
  fill_in('Notes', with: @notes)
  click_on('Upload')
end

Then(/^The example document should exist on the system$/) do
  expect(Document.find_by(notes: @notes)).to be_present
end

Then(/^I should be told I need to select a claim first$/) do
  expect(page).to have_content('add from a claim')
end
