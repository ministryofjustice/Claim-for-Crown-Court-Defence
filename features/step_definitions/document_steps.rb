Given(/^document types exist$/) do
  create(:document_type, description: 'Other')
end

When(/^I upload an example document "shorter_lorem.docx"$/) do
  @notes = SecureRandom.uuid
  select 'Other', from: 'document_document_type_id'
  attach_file(:document_document, 'features/examples/shorter_lorem.docx')
  fill_in('Notes', with: @notes)
  click_on('Upload')
end

Then(/^The example document should exist on the system$/) do
  expect(Document.find_by(notes: @notes)).to be_present
end

Then(/^the document should have a duplicate pdf version$/) do
  @doc = Document.find_by(notes: @notes)
  @doc_duplicate = @doc.document.path.slice('.')[0] + '.pdf'
  expect(@doc_duplicate).to be_present
end

Then(/^I should be told I need to select a claim first$/) do
  expect(page).to have_content('add from a claim')
end
