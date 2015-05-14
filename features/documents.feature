Feature: Manage documents

  @stub_s3_upload
  Scenario: Create a document directly
    Given document types exist
     And I visit "/documents/new"
    When I upload an example document "shorter_lorem.docx"
    Then The example document should exist on the system
     And the document should have a duplicate pdf version