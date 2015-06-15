Feature: Claim evidence checklist
  Background:
    As an advocate or case worker I need to see a checklist that
    specifies which documentary evidence has been provided.
    As an advocate I need to see an amendable checklist for
    editable claims allowing me to specify which documents I
    have provided

  Scenario: Edit checklist
    Given I am a signed in advocate
      And evidence checklist entries exist
      And a claim exists with state "draft"
     When I am on the claim edit page
     Then I should see an evidence checklist section
      And I check the first checkbox
      And I submit the form
     Then the claim should have a many-to-many record
      And I visit the claim show page
     Then I should see a list item for that evidence
