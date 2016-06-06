@javascript
Feature: Litigator fills out a final fee claim, there is an error, fixes it and submits it

  Scenario: I create a final fee claim with an error, fixing it

    Given I am a signed in litigator
    And I am not allowed to submit interim or transfer claims
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    Then I should be on the litigator new claim page

    When I select the supplier number '1A222Z'
    And I select the court 'Blackfriars Crown'
    And I select a case type of 'Contempt'
    And I enter a case number of 'A12345678'
    And I enter the case concluded date
    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference
    And I select the offence class 'E: Burglary'

    Then I click "Continue" in the claim form

    And I fill '100.75' as the fixed fee total
    And I enter the fixed fee date
    Then I should see the sidebar total '£100.75'

    And I add an expense 'Parking' with invalid date
    Then I should see the sidebar total '£135.31'

    Then I click "Continue" in the claim form

    Then I should see the error 'Expense 1 date invalid date'
    And I should see the sidebar total '£135.31'
    And I enter the date for the first expense '2016-01-02'

    Then I click "Continue" in the claim form

    And I should be on the check your claim page
    When I click "Continue"
    Then I should be on the certification page
    And I click Certify and submit claim
    Then I should be on the page showing basic claim information
