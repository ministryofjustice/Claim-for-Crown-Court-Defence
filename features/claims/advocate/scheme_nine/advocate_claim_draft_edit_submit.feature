@javascript
Feature: Advocate partially fills out a draft claim for a trial, then later edits and submits it

  Scenario: I create a claim, save it to draft and later complete it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter a case number of 'A20161234'
    And I enter trial start and end dates

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I save as draft

    Given I am later on the Your claims page
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit the claim's defendants
    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    Given I insert the VCR cassette 'features/claims/advocate/scheme_nine/claim_draft_edit'

    Then I click "Continue" in the claim form
    And I should be in the 'Graduated fees' form page

    And I should see "First day of trial"
    And the basic fee net amount should be populated with '0.00'

    And I select an advocate category of 'Junior alone'
    And the basic fee net amount should be populated with '694.00'

    And I add a daily attendance (3 to 40) fee with dates attended

    Then I click "Continue" in the claim form

    And I add a calculated miscellaneous fee 'Special preparation fee' with dates attended
    And I add a calculated miscellaneous fee 'Noting brief fee' with dates attended

    And I eject the VCR cassette

    Then I click "Continue" in the claim form

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for scheme 9

    Then I click "Continue" in the claim form

    And I upload 3 documents
    And I check the boxes for the uploaded documents
    And I add some additional information

    And I click Submit to LAA
    Then I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£1,270.37'
