@stub_s3_upload

Feature: Advocate new claim
  Scenario: Fill in claim form and submit to LAA
    Given I am a signed in advocate
      And I am on the new claim page
     When I fill in the claim details
      And I submit to LAA
     Then I should be redirected to the claim confirmation page
      And I should see the claim totals
      And the claim should be in a "submitted" state

  Scenario: Fill in claim form and submit invalid or incomplete claim to LAA
    Given I am a signed in advocate
      And I am on the new claim page
      And I submit to LAA
     Then I should see errors
      And no claim should be created

  Scenario: Fill in claim form and save to drafts
    Given I am a signed in advocate
      And I am on the new claim page
     When I save to drafts
     Then I should be redirected to the claims list page
      And I should see my claim under drafts
      And the claim should be in a "draft" state

  Scenario: Clear claim form
    Given I am a signed in advocate
      And I am on the new claim page
     When I fill in the claim details
      And I clear the form
     Then I should be redirected to the new claim page

  Scenario: Add mulitple rep orders for a single defendant
    Given I am a signed in advocate
      And I am on the new claim page
    When I click Add another representation order
      Then I see 2 fields for attaching a rep order

  Scenario: Add too many rep orders for a single defendant and remove one
    Given I am a signed in advocate
      And I am on the new claim page
    When I click Add another representation order
      And I then choose to remove the additional rep order
    Then I see 1 field for attaching a rep order

  Scenario: Submit valid draft claim to LAA
    Given I am a signed in advocate
      And a claim exists with state "draft"
     When I am on the claim edit page
      And I submit to LAA
     Then I should be on the claim confirmation page
      And the claim should be in state "submitted"

  Scenario: Attempt to submit invalid draft claim to LAA
    Given I am a signed in advocate
      And a claim exists with state "draft"
     When I am on the claim edit page
      And I make the claim invalid
      And I submit to LAA
     Then I should see errors
      And the claim should be in state "draft"

  Scenario: Edit existing submitted claim
    Given I am a signed in advocate
      And a claim exists with state "submitted"
     When I am on the claim edit page
      And I change the case number
      And I submit to LAA
     Then I should be on the claim confirmation page
      And the claim should be in state "submitted"
      And the case number should reflect the change

  Scenario: Change offence class
    Given I am a signed in advocate
      And I am on the new claim page
     When I select offence class "A: Homicide and related grave offences"
     Then the Offence category does NOT contain "Activities relating to opium"
     Then the Offence category does contain "Murder"

  Scenario: Admin specifies advocate name
    Given I am a signed in advocate admin
      And There are other advocates in my chamber
      And I am on the new claim page
     Then I can view a select of all advocates in my chamber
     When I select Advocate name "Doe, John: AC135"
      And I fill in the claim details
      And I submit to LAA
     Then I should be redirected to the claim confirmation page
      And I should see the claim totals

  Scenario: Admin fails to specify advocate name
    Given I am a signed in advocate admin
      And There are basic and non-basic fee types
      And I am on the new claim page
      And I fill in the claim details
      And I submit to LAA
     Then I should be redirected back to the claim form with error
