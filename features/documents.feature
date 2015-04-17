Feature: Manage documents

  @stub_document_upload
  Scenario: Create a document directly
    Given I visit "/documents/new"
     When I upload an example document
     Then The example document should exist on the system
