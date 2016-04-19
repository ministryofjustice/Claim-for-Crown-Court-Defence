@javascript @webmock_allow_localhost_connect
Feature: Advocate partially fills out a draft claim for a trial, then later edits and submits it

  Scenario: I create a claim, save it to draft and later complete it

    Given I am a signed in advocate
    And There are case and fee types in place
    And There are certification types in place
    And There are courts, offences and expense types in place
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    Then I should be on the new claim page

    When I select an advocate category of 'Junior alone'
    And I select a court
    And I select a case type of 'Trial'
    And I enter a case number of 'A12345678'
    And I select an offence category
    And I enter defendant, representation order and MAAT reference
    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A12345678' should be listed with a status of 'Draft'

    When I click the claim 'A12345678'
    And I edit this claim
    And I enter trial start and end dates
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    And I add a basic fee with dates attended
    And I add a daily attendance fee with dates attended
    And I add a miscellaneous fee 'Adjourned appeals' with dates attended
    And I add a miscellaneous fee 'Noting brief fee' with dates attended
    And I add an expense 'Parking'
    And I upload 3 documents
    And I check the boxes for the uploaded documents
    And I add some additional information
    And I click Submit to LAA
    Then I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the page showing basic claim information

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A12345678' should be listed with a status of 'Submitted'
