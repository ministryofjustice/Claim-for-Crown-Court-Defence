When(/^I attach valid files$/) do
  drag_and_drop_file('dropzone', 'features/examples/longer_lorem.pdf')
  expect(page).to have_selector('.dz-success')
end

Then(/^the attached file's IDs should be set in hidden inputs$/) do
  expect(page.document).to have_selector("#claim_document_ids_#{Document.first.id}", visible: false)
end

Then(/^the documents should be created with the current form_id$/) do
  expect(Document.all.map(&:form_id).uniq).to match_array([find('#claim_form_id', visible: false).value])
end

When(/^I attach invalid files$/) do
  drag_and_drop_file('dropzone', 'features/examples/minjust.html')
  expect(page).to have_selector('.dz-error')
end

Then(/^no documents should have been created$/) do
  expect(Document.count).to eq(0)
end

Given(/^I am on the new claim page and have attached valid documents$/) do
  steps <<-STEPS
    Given I am on the new claim page
     When I attach valid files
      And the attached file's IDs should be set in hidden inputs
      And the documents should be created with the current form_id
  STEPS
end

Given(/^I am on the new claim page and have attached invalid documents$/) do
  steps <<-STEPS
    Given I am on the new claim page
     When I attach invalid files
      And no documents should have been created
  STEPS
end

When(/^the page should have validation errors$/) do
  expect(page).to have_content(/This claim has \d+ errors?/)
end

Then(/^the attached files should still be visible$/) do
  document = Document.first
  within '.dropzone' do
    expect(page).to have_content(document.document_file_name)
  end
end

Then(/^the attached files should not be visible$/) do
  expect(page).to_not have_selector('.dz-preview')
end

When(/^I remove a file$/) do
  expect(Document.count).to eq(1)
  page.find(:css, 'a[id="' + Document.last.id.to_s + '"]').click
end

Then(/^the document should be deleted$/) do
  sleep 5
  expect(Document.count).to eq(0)
end

Then(/^the document's claim and advocate IDs should be set$/) do
  claim = Claim::BaseClaim.first
  document = claim.documents.last
  expect(document.external_user_id).to eq(claim.external_user_id)
end

Given(/^a draft claim with documents exists$/) do
  claim = create(:draft_claim, external_user: @advocate)
  create(:document, claim: claim, external_user: @advocate, creator_id: @advocate.user.id)
end

Given(/^I am on the edit page for the claim$/) do
  claim = Claim::BaseClaim.first
  visit edit_external_users_claim_path(claim)
end

Then(/^I should see the previously uploaded documents$/) do
  claim = Claim::BaseClaim.first

  within '.previously-uploaded' do
    expect(page).to have_content(claim.documents.first.document_file_name)
  end
end

When(/^I remove a previously uploaded document$/) do
  claim = Claim::BaseClaim.first
  document_id = claim.documents.first.id

  within "#document_#{document_id}" do
    click_on 'Remove'
    sleep 1
    wait_for_ajax
  end

  expect(page).to_not have_selector("#document_#{document_id}")
end

Then(/^the document should no longer be visible$/) do
  within '.previously-uploaded' do
    expect(page).to have_selector('li', count: 0)
  end
end

When(/^I attach a file$/) do
  drag_and_drop_file('dropzone', 'features/examples/longer_lorem.pdf')
end

Given(/^the maximum allowed files are (\d+)$/) do |max_allowed_files|
  allow(Settings).to receive(:max_document_upload_count).and_return max_allowed_files.to_i
end
