@javascript @webmock_allow_localhost_connect

Feature: Claim document upload
  Background:
    As an advocate I want to be able to attach multiple files as evidence
    to suppport my claim.

    Given I am a signed in advocate

  Scenario: Attach valid files
    Given I am on the new claim page
     When I attach valid files
      And the attached file's IDs should be set in hidden inputs
      And the documents should be created with the current form_id

  Scenario: Attach invalid files
    Given I am on the new claim page
     When I attach invalid files
      And no documents should have been created

  Scenario: Attach valid files and attempt to submit to LAA
    Given I am on the new claim page and have attached valid documents
     When I submit to LAA
      And the page should have validation errors
     Then the attached files should still be visible

  Scenario: Attach invalid files and attempt to submit to LAA
    Given I am on the new claim page and have attached invalid documents
     When I submit to LAA
      And the page should have validation errors
     Then the attached files should not be visible
      And no documents should have been created

  @wip
  Scenario: Attach valid files then remove
    Given I am on the new claim page and have attached valid documents
     When I remove a file
     Then the document should be deleted

  Scenario: Save to drafts after attaching documents
    Given I am on the new claim page and have attached valid documents
     When I save to drafts
     Then the document's claim and advocate IDs should be set

  Scenario: Edit a draft claim and view previously uploaded documents
    Given a draft claim with documents exists
      And I am on the edit page for the claim
     Then I should see the previously uploaded documents

  Scenario: Edit a draft claim and add another document
    Given a draft claim with documents exists
      And I am on the edit page for the claim
     Then I should see the previously uploaded documents
     When I attach valid files
      And I save to drafts
     Then the document's claim and advocate IDs should be set

  @wip
  Scenario: Remove previously uploaded document from draft claim
    Given a draft claim with documents exists
      And I am on the edit page for the claim
     Then I should see the previously uploaded documents
     When I remove a previously uploaded document
     Then the document should be deleted
      And the document should no longer be visible

  Scenario: Attempt to attach more than the maximum allowed files
    Given I am on the new claim page
      And the maximum allowed files are 0
     When I attach a file
     Then no documents should have been created
