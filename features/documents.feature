Feature: Manage documents

  Background:
    Given an "advocate" user account exists
    And that advocate signs in

  @stub_s3_upload
  Scenario: Create a document directly
    Given document types exist
     And I visit "/documents/new"
    When I upload an example document
    Then The example document should exist on the system
