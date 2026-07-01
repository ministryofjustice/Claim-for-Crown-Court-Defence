@javascript
Feature: Advocate submits an LGFS Fee Scheme 17 claim for a Fixed fee (Appeal against conviction)

  @fee_calc_vcr
  Scenario: I create and submit an Appeal against conviction claim

    Given the current date is '2026-06-24'
    And I am a signed in advocate
    And I am on the 'Your claims' page

    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Caernarfon'
    And I select a case type of 'Appeal against conviction'
    And I enter a case number of 'A20181234'
    And I enter scheme 17 main hearing date
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I enter defendant, scheme 17 representation order and MAAT reference
    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/claims/advocate/scheme/seventeen/fixed_fee_calculations'

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

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Travel expenses' form page

    Then I click "Continue" in the claim form
    And I should be in the 'Supporting evidence' form page

    When I click "Continue" in the claim form
    Then I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page
    
    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the claim confirmation page
    And I should see a page title "Thank you for submitting your claim"