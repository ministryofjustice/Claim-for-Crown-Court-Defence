Feature: Manage documents

  @stub_s3_upload
  Scenario: Create a document directly
    Given document types exist
     And I visit "/documents/new"
    When I upload an example document
    Then The example document should exist on the system
