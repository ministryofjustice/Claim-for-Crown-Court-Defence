@javascript
Feature: Advocate tries to submit a claim for a Fixed fee (Appeal against conviction)

  @fee_calc_vcr
  Scenario: I create an Appeal against conviction claim, and use the back button to invalidate it

    Given I am a signed in advocate
    And I am on the 'Your claims' page

    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Caernarfon'
    And I select a case type of 'Appeal against conviction'
    And I enter a case number of 'A20181234'
    And I enter scheme 11 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, scheme 11 representation order and MAAT reference
    And I add another defendant, scheme 11 representation order and MAAT reference

    Then I click "Continue" in the claim form
    Then I click the link 'Back'
    And I should be in the 'Defendant details' form page

    Then I should see 'Defendant 1'
    And I should see 'Defendant 2'
    And I should see 2 representation orders

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/claims/advocate/scheme_eleven/fixed_fee_calculations'

    And I should see the advocate categories 'Junior,Leading junior,KC'
    And I select an advocate category of 'Junior'

    And I select the 'Appeals to the crown court against conviction' fixed fee
    Then the fixed fee 'Appeals to the crown court against conviction' should have a rate of '330.00' and a hint of 'Number of days'
    Then the summary total should equal '£330.00'

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    Then I click the link 'Back'
    And I should be in the 'Fixed fees' form page

    When I uncheck the govuk checkbox "Appeals to the crown court against conviction"
    Then I click "Continue" in the claim form
    And I should be in the 'Fixed fees' form page
    And I should see govuk error summary with 'Total value claimed must be greater than £0.00'
    And I eject the VCR cassette
