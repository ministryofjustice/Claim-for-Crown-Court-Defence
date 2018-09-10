@javascript
Feature: Advocate completes fixed fee page using calculator

  @fee_calc_vcr
  Scenario: I create a fixed fee claim using calculated value, then submit it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Blackfriars'
    And I select a case type of 'Appeal against conviction'
    And I enter a case number of 'A20161234'

    Then I click "Continue" in the claim form

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/fee_calculator/fixed_fee_calculator'

    And I select an advocate category of 'Junior alone'
    And I add a fixed fee 'Appeals to the crown court against conviction'
    And I add a fixed fee 'Number of cases uplift' with case numbers
    And I add a fixed fee 'Number of defendants uplift'
    And I add a fixed fee 'Standard appearance fee'

    Then the fixed fee 'Appeals to the crown court against conviction' should have a rate of '130.00'
    Then the fixed fee 'Number of cases uplift' should have a rate of '26.00'
    Then the fixed fee 'Number of defendants uplift' should have a rate of '26.00'
    Then the fixed fee 'Standard appearance fee' should have a rate of '87.00'

    And I select an advocate category of 'QC'
    Then the fixed fee 'Appeals to the crown court against conviction' should have a rate of '260.00'
    Then the fixed fee 'Number of cases uplift' should have a rate of '52.00'
    Then the fixed fee 'Number of defendants uplift' should have a rate of '52.00'
    Then the fixed fee 'Standard appearance fee' should have a rate of '173.00'

    Then I amend the fixed fee 'Appeals to the crown court against conviction' to have a quantity of 2
    Then the fixed fee 'Appeals to the crown court against conviction' should have a rate of '260.00'
    Then the fixed fee 'Number of cases uplift' should have a rate of '104.00'
    Then the fixed fee 'Number of defendants uplift' should have a rate of '104.00'
    Then the fixed fee 'Standard appearance fee' should have a rate of '173.00'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I am on the miscellaneous fees page
