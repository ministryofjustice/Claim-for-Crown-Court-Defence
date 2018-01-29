@javascript
Feature: Advocate submits a claim for a Contempt case

  Scenario: I create a contempt claim, then submit it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    Then I should be on the new claim page

    When I select an advocate category of 'Junior alone'
    And I select the court 'Blackfriars'
    And I select a case type of 'Contempt'
    And I enter a case number of 'A20161234'

    Then I click "Continue" in the claim form

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    Then I click "Continue" in the claim form

    And I add a miscellaneous fee 'Adjourned appeals' with dates attended
    And I add a fixed fee 'Contempt'
    And I add a fixed fee 'Number of cases uplift' with case numbers
    And I add an expense 'Parking'
    And I upload 3 documents
    And I check the boxes for the uploaded documents
    And I add some additional information

    Then I click Submit to LAA
    And I should be on the check your claim page
    And I should see 'Handling stolen goods'
    And I should see 'G: Other offences of dishonesty between £30,001 and £100,000'

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the page showing basic claim information

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£109.75'
