@javascript
Feature: Advocate can add and remove fee scheme 16 miscelleaneous fees

  @fee_calc_vcr
  Scenario: Advocate can add and remove miscellaneous fees

    Given the current date is '2023-11-16'
    And I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Caernarfon'
    And I select a case type of 'Appeal against conviction'
    And I enter a case number of 'A20181234'
    And I enter scheme 16 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant' form page

    And I enter defendant, scheme 16 representation order and MAAT reference
    And I add another defendant, scheme 16 representation order and MAAT reference

    Then I click "Continue" in the claim form
    Then I click the link 'Back'
    And I should be in the 'Defendant' form page

    Then I should see 'Defendant 1'
    And I should see 'Defendant 2'
    And I should see 2 representation orders

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/claims/advocate/scheme_sixteen/misc_fee_removal'

    And I should see the advocate categories 'Junior,Leading junior,KC'
    And I select an advocate category of 'Junior'

    And I select the 'Appeals to the crown court against conviction' fixed fee
    Then the fixed fee 'Appeals to the crown court against conviction' should have a rate of '380.00' and a hint of 'Number of days'
    Then the summary total should equal '£380.00'

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
    When I click on misc fees helper text
    Then I should see the following miscellaneous fees listed:
      | Abuse of process hearings                             |
      | Application to dismiss a charge                       |
      | Confiscation hearings                                 |
      | Deferred sentence hearings                            |
      | Deferred sentence hearings uplift                     |
      | Further case management hearing                       |
      | Ground rules hearing                                  |
      | Hearings relating to admissibility of evidence        |
      | Hearings relating to disclosure                       |
      | Noting brief fee                                      |
      | Proceeds of crime hearings                            |
      | Public interest immunity hearings                     |
      | Research of very unusual or novel factual issue       |
      | Research of very unusual or novel point of law        |
      | Sentence hearings                                     |
      | Sentence hearings uplift                              |
      | Special preparation fee                               |
      | Standard appearance fee uplift                        |
      | Trial not proceed                                     |
      | Trial not proceed uplift                              |
      | Unsuccessful application to vacate a guilty plea      |
      | Wasted preparation fee                                |
      | Written / oral advice                                 |
    And I add a govuk calculated miscellaneous fee 'Abuse of process hearings (half day)' with quantity of '1'
    And I add a govuk calculated miscellaneous fee 'Hearings relating to disclosure (whole day)' with quantity of '1'
    And I click "Continue" in the claim form
    Then I should be in the 'Travel expenses' form page

    When I click the link 'Back'
    And I should be in the 'Miscellaneous fees' form page
    Then the last 'miscellaneous' fee rate should be populated with '276.00'

    When I click last remove link
    Then the last 'miscellaneous' fee rate should be populated with '151.00'

    When I click "Continue" in the claim form
    Then I should be in the 'Travel expenses' form page

    When I click the link 'Back'
    Then I should be in the 'Miscellaneous fees' form page
    And the last 'miscellaneous' fee rate should be populated with '151.00'

    When I click last remove link
    And I eject the VCR cassette
    Then I should not see 'Remove'
