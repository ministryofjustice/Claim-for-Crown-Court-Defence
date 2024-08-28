@javascript
@fee_calc_vcr
Feature: litigator completes fixed fee page using calculator

  Scenario: I create a fee scheme 9 fixed fee claim using london rates

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS test misc fee calculation'
    And I select a case type of 'Appeal against conviction'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161298'
    And I enter the case concluded date '2018-04-01'
    And I select 'true' to London rates

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, LGFS representation order and MAAT reference
    And I add another defendant, LGFS representation order and MAAT reference

    Given I insert the VCR cassette 'features/fee_calculator/litigator/misc_fee_calculator_london'

    Then I click "Continue" in the claim form
    And I should be in the 'Fixed fees' form page

    And I fill '2018-11-01' as the fixed fee date
    And I fill '1' as the fixed fee quantity

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    When I add a litigator calculated miscellaneous fee 'Special preparation fee' with quantity of '3'

    Then the following govuk fee details should exist:
      | section       | fee_description                                    | rate   | hint                            | help |
      | miscellaneous | Special Preparation fee                            | 43.12  | Number of hours                 | true |

    Then I eject the VCR cassette
    And I save as draft

    Then I should see 'Draft claim saved'
    And Claim 'A20161298' should be listed with a status of 'Draft' and a claimed amount of '£574.60'

  Scenario: I create a fee scheme 10 fixed fee claim using calculated value

    Given  the current date is '2022-10-30'
    And I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS misc fixed fee calculation'
    And I select a case type of 'Appeal against conviction'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161299'
    And I enter the case concluded date '2022-10-29'

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, LGFS Scheme 10 representation order and MAAT reference
    And I add another defendant, LGFS Scheme 10 representation order and MAAT reference

    Given I insert the VCR cassette 'features/fee_calculator/litigator/fixed_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Fixed fees' form page

    And I fill '2022-10-01' as the fixed fee date
    And I fill '1' as the fixed fee quantity

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page


    When I add a litigator calculated miscellaneous fee 'Special preparation fee' with quantity of '3'

    Then the following govuk fee details should exist:
      | section       | fee_description                                    | rate   | hint                            | help |
      | miscellaneous | Special Preparation fee                            | 49.59  | Number of hours                 | true |

    Then I eject the VCR cassette
    And I save as draft

    Then I should see 'Draft claim saved'
    And Claim 'A20161298' should be listed with a status of 'Draft' and a claimed amount of '£660.79'

