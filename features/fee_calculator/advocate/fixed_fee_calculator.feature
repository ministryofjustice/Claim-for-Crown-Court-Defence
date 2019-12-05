@javascript
Feature: Advocate completes fixed fee page using calculator

  @fee_calc_vcr
  Scenario: I create a fixed fee claim using calculated value

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    Then the page should be accessible within "#content"
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then the page should be accessible within "#content"
    Then I should be on the new claim page
    Then the page should be accessible within "#content"

    And I select the court 'Blackfriars'
    And I select a case type of 'Appeal against conviction'
    And I enter a case number of 'A20161234'
    Then the page should be accessible within "#content"

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    Then the page should be accessible within "#content"

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference
    Then the page should be accessible within "#content"

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/fee_calculator/advocate/fixed_fee_calculator'

    When I select an advocate category of 'Junior alone'
    And I select the 'Appeals to the crown court against conviction' fixed fee
    And I select the 'Number of cases uplift' fixed fee with case numbers
    And I select the 'Number of defendants uplift' fixed fee
    And I select the 'Standard appearance fee' fixed fee

    Then the following fee details should exist:
      | section | fee_description                               | rate   | hint                            | help |
      | fixed   | Appeals to the crown court against conviction | 130.00 | Number of days                  | true |
      | fixed   | Number of cases uplift                        | 26.00  | Number of additional cases      | true |
      | fixed   | Number of defendants uplift                   | 26.00  | Number of additional defendants | true |
      | fixed   | Standard appearance fee                       | 87.00  | Number of days                  | true |

    When I select an advocate category of 'QC'
    Then the following fee details should exist:
      | section | fee_description                               | rate   |
      | fixed   | Appeals to the crown court against conviction | 260.00 |
      | fixed   | Number of cases uplift                        | 52.00  |
      | fixed   | Number of defendants uplift                   | 52.00  |
      | fixed   | Standard appearance fee                       | 173.00 |

    When I amend the fixed fee 'Appeals to the crown court against conviction' to have a quantity of '2'
    Then the following fee details should exist:
      | section | fee_description                               | rate   |
      | fixed   | Appeals to the crown court against conviction | 260.00 |
      | fixed   | Number of cases uplift                        | 104.00 |
      | fixed   | Number of defendants uplift                   | 104.00 |
      | fixed   | Standard appearance fee                       | 173.00 |
    Then the page should be accessible within "#content"

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I am on the miscellaneous fees page
    Then the page should be accessible within "#content"

  @fee_calc_vcr
  Scenario: I create a fixed fee which has a fixed amount calculated value

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    Then the page should be accessible within "#content"
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then the page should be accessible within "#content"
    Then I should be on the new claim page
    Then the page should be accessible within "#content"

    And I select the court 'Blackfriars'
    And I select a case type of 'Elected cases not proceeded'
    And I enter a case number of 'A20161234'
    Then the page should be accessible within "#content"

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    Then the page should be accessible within "#content"

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference
    Then the page should be accessible within "#content"

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/fee_calculator/advocate/fixed_fee_calculator'

    And I select an advocate category of 'Junior alone'
    And I select the 'Elected case not proceeded' fixed fee
    And I select the 'Number of cases uplift' fixed fee with case numbers
    And I select the 'Number of defendants uplift' fixed fee

    Then the following fee details should exist:
      | section | fee_description             | rate   | hint                            | help |
      | fixed   | Elected case not proceeded  | 194.00 | Number of days                  | true |
      | fixed   | Number of cases uplift      | 38.80  | Number of additional cases      | true |
      | fixed   | Number of defendants uplift | 38.80  | Number of additional defendants | true |

    When I select an advocate category of 'QC'
    Then the following fee details should exist:
      | section | fee_description             | rate   | hint                            | help |
      | fixed   | Elected case not proceeded  | 194.00 | Number of days                  | true |
      | fixed   | Number of cases uplift      | 38.80  | Number of additional cases      | true |
      | fixed   | Number of defendants uplift | 38.80  | Number of additional defendants | true |
    Then the page should be accessible within "#content"

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I am on the miscellaneous fees page
    Then the page should be accessible within "#content"

    And all the fixed fees should have their price_calculated values set to true
