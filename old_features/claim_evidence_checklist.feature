Feature: Claim evidence checklist
  Background:
    As an advocate or case worker I need to see a checklist that
    specifies which documentary evidence has been provided.
    As an advocate I need to see an amendable checklist for
    editable claims allowing me to specify which documents I
    have provided

  Scenario: Edit claim checklist
    Given I am a signed in advocate
      And a claim exists with state "draft"
     When I am on the claim edit page
     Then I should see an evidence checklist section
      And I check the first checkbox
      And I submit to LAA
      And I visit the claim show page
     Then I should see a list item for "Representation order" evidence

  Scenario: New claim checklist
    Given I am a signed in advocate
      And There are case types in place
     When I am on the new claim page
     Then I should see an evidence checklist section
      And I fill in the claim details
      And I submit to LAA
      And I visit the claim show page
     Then I should see a list item for "Representation order" evidence
