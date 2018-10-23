@javascript
Feature: litigator completes fixed fee page using calculator

  @fee_calc_vcr
  Scenario: I create a fixed fee claim using calculated value

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS test fixed fee calculation'
    And I select a case type of 'Appeal against conviction'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2018-04-01'

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page

    And I enter defendant, post agfs reform representation order and MAAT reference
    And I add another defendant, post agfs reform representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Fees' form page

    # Given I insert the VCR cassette 'features/fee_calculator/litigator/fixed_fee_calculator'
    # TODO: below
    Then the 'fixed' fee 'Appeals to the crown court against conviction' should have a rate of '349.47' and a hint of 'Number of days'
    And I enter a fixed fee quantity of 2
    Then I should see in the sidebar total '£698.94'
    Then I should see in the sidebar vat total '£0.00'

    # And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
