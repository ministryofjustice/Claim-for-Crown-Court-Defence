@javascript
Feature: Advocate admin submits a claim for a Trial case

  Scenario: I create a trial claim, then submit it
    Given I am a signed in advocate admin
    And There are other advocates in my provider
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    When I choose 'Doe, John (AC135)' as the instructed advocate
    And I enter a case number of 'A20161234'
    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    And 6+ advocates exist for my provider
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit the claim's case details

    When I select 'Doe, John (AC135)' as the instructed advocate
    And I select the court 'Blackfriars'
    And I select a case type of 'Retrial'
    Then I should see retrial fields
    And I select a case type of 'Trial'
    And I enter trial start and end dates

    Then I click "Continue" in the claim form
    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I select the offence category 'Activities relating to opium'

    Then I click "Continue" in the claim form
    And I select an advocate category of 'Junior alone'
    And I add a basic fee with dates attended
    And I add a number of cases uplift fee with additional case numbers

    Then I click "Continue" in the claim form

    And I add a miscellaneous fee 'Adjourned appeals' with dates attended
    And I add a miscellaneous fee 'Noting brief fee' with dates attended

    Then I click "Continue" in the claim form

    And I add an expense 'Hotel accommodation'

    Then I click "Continue" in the claim form

    And I upload 3 documents
    And I check the boxes for the uploaded documents
    And I add some additional information

    Then I click Submit to LAA
    And I should be on the check your claim page
    And I should see 'Activities relating to opium'
    And I should see 'B: Offences involving serious violence or damage and serious drug offences'

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the page showing basic claim information

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£368.55'
