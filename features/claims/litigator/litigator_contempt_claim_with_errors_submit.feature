@javascript
Feature: Litigator fills out a final fee claim, there is an error, fixes it and submits it

  Scenario: I create a final fee claim with an error, fixing it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I select the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I select a case type of 'Contempt'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date

    Then I click "Continue" in the claim form

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    And I fill '100.75' as the fixed fee total
    And I enter the fixed fee date
    Then I should see in the sidebar total '£100.75'
    Then I should see in the sidebar vat total '£0.00'

    And I add an expense 'Parking' with total '99.25' and VAT '15.50' with invalid date
    Then I should see in the sidebar total '£215.50'
    Then I should see in the sidebar vat total '£15.50'

    Then I click "Continue" in the claim form

    Then I should see the error 'Expense 1 date invalid date'
    And I should see in the sidebar total '£215.50'
    Then I should see in the sidebar vat total '£15.50'

    And I enter the date for the first expense '2016-01-02'
    Then I click "Continue" in the claim form

    And I should be on the check your claim page
    When I click "Continue"
    Then I should be on the certification page
    And I click Certify and submit claim
    Then I should be on the page showing basic claim information
