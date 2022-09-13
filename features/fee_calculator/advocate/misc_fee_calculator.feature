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
    And I enter scheme 9 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/fee_calculator/advocate/misc_fee_calculator'

    And I select an advocate category of 'KC'
    And I select the 'Appeals to the crown court against conviction' fixed fee

    Then I click "Continue" in the claim form

    When I add a govuk calculated miscellaneous fee 'Wasted preparation fee'
    And I add a govuk calculated miscellaneous fee 'Hearings relating to disclosure (whole day)' with quantity of '2'
    And I add a govuk calculated miscellaneous fee 'Hearings relating to disclosure (whole day uplift)' with quantity of '2'

    Then the following govuk fee details should exist:
      | section       | fee_description                                    | rate   | hint                            | help |
      | miscellaneous | Wasted preparation fee                             | 74.00  | Number of hours                 | true |
      | miscellaneous | Hearings relating to disclosure (whole day)        | 497.00 | Number of days                  | true |
      | miscellaneous | Hearings relating to disclosure (whole day uplift) | 198.80 | Number of additional defendants | true |

    When I amend the govuk miscellaneous fee 'Hearings relating to disclosure (whole day)' to have a quantity of '3'
    Then the following govuk fee details should exist:
      | section       | fee_description                                    | rate   | hint                            | help |
      | miscellaneous | Wasted preparation fee                             | 74.00  | Number of hours                 | true |
      | miscellaneous | Hearings relating to disclosure (whole day)        | 497.00 | Number of days                  | true |
      | miscellaneous | Hearings relating to disclosure (whole day uplift) | 298.20 | Number of additional defendants | true |

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Travel expenses' form page
    And all the misc fees should have their price_calculated values set to true

    And I save as draft
    Then I should see 'Draft claim saved'
    And Claim 'A20174321' should be listed with a status of 'Draft' and a claimed amount of '£2,905.68'
