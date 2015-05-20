def upload_a_document
  @notes = SecureRandom.uuid
  select 'Other', from: 'document_document_type_id'
  attach_file(:document_document, 'features/examples/shorter_lorem.docx')
  fill_in('Notes', with: @notes)
  click_on('Upload')
end


Given(/^document types exist$/) do
  create(:document_type, description: 'Other')
end

When(/^I upload an example document$/) do
  upload_a_document
end

When(/^a document exists that belongs to the advocate$/) do
  @document = create(:document, advocate: @advocates.first)
end

Then(/^an anonymous user cannot access the document$/) do
  click 'Sign out' rescue nil
  visit document_url(@document)
  expect(page.status_code).to eq(500)
  expect(page).to have_content(/not authorized/i)
end

Then(/^the advocate can download the document$/) do
  visit document_url(@document)
  expect(page.status_code).to eq(200)
end

Then(/^The example document should exist on the system$/) do
  expect(Document.find_by(notes: @notes)).to be_present
end

Then(/^I should be told I need to select a claim first$/) do
  expect(page).to have_content('add from a claim')
end
