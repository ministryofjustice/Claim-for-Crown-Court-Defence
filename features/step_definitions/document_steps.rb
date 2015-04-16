When(/^I upload an example document$/) do
  attach_file(:document_document, 'features/examples/shorter_lorem.docx')
  click_on('Upload')
end

Then(/^The example document should exist on the system$/) do
  expect(Document.find_by(document_file_name: 'shorter_lorem.docx')).to be_present
end
