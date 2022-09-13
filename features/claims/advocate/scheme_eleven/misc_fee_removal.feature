@javascript
Feature: Advocate can add and remove miscelleaneous fees

  @fee_calc_vcr
  Scenario: Advocate can add and remove miscellaneous fees

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Caernarfon'
    And I select a case type of 'Appeal against conviction'
    And I enter a case number of 'A20181234'
    And I enter scheme 11 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant' form page

    And I enter defendant, scheme 11 representation order and MAAT reference
    And I add another defendant, scheme 11 representation order and MAAT reference

    Then I click "Continue" in the claim form
    Then I click the link 'Back'
    And I should be in the 'Defendant' form page

    Then I should see 'Defendant 1'
    And I should see 'Defendant 2'
    And I should see 2 representation orders

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/claims/advocate/scheme_eleven/misc_fee_removal'

    And I should see the advocate categories 'Junior,Leading junior,KC'
    And I select an advocate category of 'Junior'

    And I select the 'Appeals to the crown court against conviction' fixed fee
    Then the fixed fee 'Appeals to the crown court against conviction' should have a rate of '330.00' and a hint of 'Number of days'
    Then the summary total should equal '£330.00'

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
    And I add a govuk calculated miscellaneous fee 'Abuse of process hearings (half day)' with quantity of '1'
    And I add a govuk calculated miscellaneous fee 'Hearings relating to disclosure (whole day)' with quantity of '1'
    And I click "Continue" in the claim form
    Then I should be in the 'Travel expenses' form page

    When I click the link 'Back'
    And I should be in the 'Miscellaneous fees' form page
    Then the last 'miscellaneous' fee rate should be populated with '240.00'

    When I click last remove link
    Then the last 'miscellaneous' fee rate should be populated with '131.00'

    When I click "Continue" in the claim form
    Then I should be in the 'Travel expenses' form page

    When I click the link 'Back'
    Then I should be in the 'Miscellaneous fees' form page
    And the last 'miscellaneous' fee rate should be populated with '131.00'

    When I click last remove link
    Then I should not see 'Remove'
