Then(/^the document should have a duplicate pdf version$/) do
  upload_a_document
end

When(/^a document exists that belongs to the(?: (\d+)\w+)? advocate$/) do |cardinality|
  card = cardinality.nil? ? 0 : cardinality.to_i - 1
  @document = create(:document, external_user: @advocates[card])
end

Then(/^an anonymous user cannot access the document$/) do
  click 'Sign out' rescue nil
  visit document_url(@document)
  expect(page).to have_content(/unauthorised/i)
end

Then(/^(?:the|that) advocate can(not)? access the document$/) do |cannot_access|
  visit download_document_url(@document)
  if cannot_access.present?
    expect(page).to have_content(/unauthorised/i)
  else
    expect(current_url).to eq(download_document_url(@document))
  end
end

Then(/^(?:the|that) case worker can access all documents$/) do
  Document.all.each do |document|
    visit download_document_url(document)
    expect(page.status_code).to eq(200)
  end
end

Then(/^I should be told I need to select a claim first$/) do
  expect(page).to have_content('add from a claim')
end
