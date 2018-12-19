@javascript
Feature: Advocate completes misc fee page using calculator

  @fee_calc_vcr
  Scenario: I create a misc fee claim using calculated value, then submit it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Blackfriars'
    And I select a case type of 'Appeal against conviction'
    And I enter a case number of 'A20174321'

    Then I click "Continue" in the claim form

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/fee_calculator/advocate/misc_fee_calculator'

    And I select an advocate category of 'QC'
    And I select the 'Appeals to the crown court against conviction' fixed fee

    Then I click "Continue" in the claim form


    And I add a calculated miscellaneous fee 'Wasted preparation fee'
    And I add a calculated miscellaneous fee 'Hearings relating to disclosure (whole day)' with quantity of '2'
    And I add a calculated miscellaneous fee 'Hearings relating to disclosure (whole day uplift)' with quantity of '2'
    Then the 'miscellaneous' fee 'Wasted preparation fee' should have a rate of '74.00' and a hint of 'Number of hours'
    Then the 'miscellaneous' fee 'Hearings relating to disclosure (whole day)' should have a rate of '497.00' and a hint of 'Number of days'
    Then the 'miscellaneous' fee 'Hearings relating to disclosure (whole day uplift)' should have a rate of '198.80' and a hint of 'Number of additional defendants'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Travel expenses' form page
    And all the misc fees should have their price_calculated values set to true

    And I save as draft
    Then I should see 'Draft claim saved'
    And Claim 'A20174321' should be listed with a status of 'Draft' and a claimed amount of '£2,070.72'
