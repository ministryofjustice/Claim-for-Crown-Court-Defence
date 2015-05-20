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

When(/^a document exists that belongs to the(?: (\d+)\w+)? advocate$/) do |cardinality|
  card = cardinality.nil? ? 0 : cardinality.to_i - 1
  @document = create(:document, advocate: @advocates[card])
end

Then(/^an anonymous user cannot access the document$/) do
  click 'Sign out' rescue nil
  visit document_url(@document)
  expect(page.status_code).to eq(500)
  expect(page).to have_content(/not authorized/i)
end

Then(/^(?:the|that) advocate can(not)? access the document$/) do |cannot_access|
  expected_status = cannot_access.present? ? 500 : 200
  visit download_document_url(@document)
  expect(page.status_code).to eq(expected_status)
  visit document_url(@document)
  expect(page.status_code).to eq(expected_status)
end

Then(/^(?:the|that) case worker can access all documents$/) do
  Document.all.each do |document|
    visit download_document_url(document)
    expect(page.status_code).to eq(200)
    visit document_url(document)
    expect(page.status_code).to eq(200)
  end
end

Then(/^The example document should exist on the system$/) do
  expect(Document.find_by(notes: @notes)).to be_present
end

Then(/^I should be told I need to select a claim first$/) do
  expect(page).to have_content('add from a claim')
end
