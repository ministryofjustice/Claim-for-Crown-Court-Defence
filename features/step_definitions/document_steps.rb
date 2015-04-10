When(/^I upload an example document$/) do
  attach_file(:document, 'features/examples/shorter_lorem.docx')
end

Then(/^The example document should exist on the system$/) do
  pending
end
