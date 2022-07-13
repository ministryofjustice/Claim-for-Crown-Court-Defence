@javascript
Feature: Litigator creates an Elected Case Not Proceeded final fee claim

  @fee_calc_vcr
  Scenario: I create an Elected Case Not Proceeded fee claim under LGFS fee scheme 9 and complete it
    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page
    And I should see a page title "Enter case details for litigator final fees claim"
    And I should see 3 supplier number radios

    When I select a case type of 'Elected cases not proceeded'
    And I select the court 'Blackfriars'
    And I enter a case number of 'T20221234'
    And I enter the case concluded date '2022-07-01'
    Then I click "Continue" I should be on the 'Case details' page and see a "Choose a supplier number" error

    When I choose the supplier number '1A222Z'
    And I click "Continue" in the claim form
    Then I should be in the 'Defendant details' form page
    And I should see a page title "Enter defendant details for litigator final fees claim"

    And I enter defendant, LGFS scheme 9 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Fixed fees' form page

  Scenario: I create an Elected Case Not Proceeded fee claim under LGFS fee scheme 10 and receive a validation error
    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page
    And I should see a page title "Enter case details for litigator final fees claim"
    And I should see 3 supplier number radios

    When I select a case type of 'Elected cases not proceeded'
    And I select the court 'Blackfriars'
    And I enter a case number of 'T20221234'
    And I enter the case concluded date '2022-07-01'
    Then I click "Continue" I should be on the 'Case details' page and see a "Choose a supplier number" error

    When I choose the supplier number '1A222Z'
    And I click "Continue" in the claim form
    Then I should be in the 'Defendant details' form page
    And I should see a page title "Enter defendant details for litigator final fees claim"

    And I enter defendant, LGFS scheme 10 representation order and MAAT reference 

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page
    And I should see govuk error summary with 'You cannot claim for an Elected Case Not Proceeded on or after 01/06/2022'
