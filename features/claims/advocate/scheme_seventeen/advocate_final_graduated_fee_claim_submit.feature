@javascript
Feature: Advocate submits an AGFS Fee Scheme 17 final graduated fee claims

  @fee_calc_vcr
  Scenario: I create and submit a trial claim with a graduated fee and miscellaneous fees
    Given the current date is '2026-06-24'
    And I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page
    And I should see a page title "Enter case details for advocate final fees claim"

    When I enter a case number of 'A20201234'
    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter scheme 17 trial start and end dates
    And I enter scheme 17 main hearing date
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I should see a page title "Enter defendant details for advocate final fees claim"

    When I enter defendant, scheme 17 representation order and MAAT reference
    And I click "Continue" in the claim form
    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    And I insert the VCR cassette 'features/claims/advocate/scheme_seventeen/graduated_fee_calculations'
    And I select the first search result
    Then I should be in the 'Graduated fees' form page
    And I should see a page title "Enter graduated fees for advocate final fees claim"
    And I should see the advocate categories 'Junior,Leading junior,KC'
    And I should see the scheme 17 applicable basic fees based on the govuk checkbox group
    And the basic fee net amount should be populated with '0.00'

    When I select an advocate category of 'Junior'
    Then the basic fee net amount should be populated with '1392.00'

    When I select the govuk field 'Number of cases uplift' basic fee with quantity of 1 with case numbers
    And I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page
    And I should see "This claim may be eligible for 'Additional preparation fee' and 'Unused materials (up to 3 hours)'"
    When I add a govuk calculated miscellaneous fee 'Additional preparation fee'

    When I click "Continue" in the claim form
    And I click the link 'Back'
    Then I should be in the 'Miscellaneous fees' form page
    And I should see "This claim may be eligible for 'Unused materials (up to 3 hours)'"

    When I add a govuk calculated miscellaneous fee 'Unused materials (up to 3 hours)'
    And I add a govuk calculated miscellaneous fee 'Unused materials (over 3 hours)' with quantity of '5'
    And I should see 'You need to add a separate "Unused material (up to 3 hours)" fee for the first 3 hours'
    And I add a govuk calculated miscellaneous fee 'Paper heavy case'
    And I add a govuk calculated miscellaneous fee 'Deferred sentence hearings'
    Then the following govuk fee details should exist:
      | section       | fee_description                  | rate   | hint            | help |
      | miscellaneous | Additional preparation fee       | 81.00  | Number of fees  | true |
      | miscellaneous | Unused materials (up to 3 hours) | 67.95  | Number of hours | true |
      | miscellaneous | Unused materials (over 3 hours)  | 45.30  | Number of hours | true |
      | miscellaneous | Paper heavy case                 | 45.30  | Number of hours | true |
      | miscellaneous | Deferred sentence hearings       | 201.00 | Number of days  | true |

    And I eject the VCR cassette

    When I click "Continue" in the claim form
    Then I should be in the 'Travel expenses' form page
    
    When I click "Continue" in the claim form
    Then I should be in the 'Supporting evidence' form page
    Then I upload the document 'indictment.pdf'
    And I check the evidence boxes for 'Copy of the indictment'
    And I add some additional information

    When I click "Continue" in the claim form
    Then I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the claim confirmation page
    And I should see a page title "Thank you for submitting your claim"

  @fee_calc_vcr
  Scenario: I create and submit a guilty plea claim with a fixed fee and miscellaneous fees

    Given the current date is '2026-06-24'
    And I am a signed in advocate
    And I am on the 'Your claims' page

    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Caernarfon'
    And I select a case type of 'Guilty plea'
    And I enter a case number of 'A20181234'
    And I enter scheme 17 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I enter defendant, scheme 17 representation order and MAAT reference

    When I click "Continue" in the claim form
    Then I should be in the 'Offence details' form page
    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    And I insert the VCR cassette 'features/claims/advocate/scheme_seventeen/graduated_fee_calculations'
    And I select the first search result
    Then I should be in the 'Graduated fees' form page
    And I should see a page title "Enter graduated fees for advocate final fees claim"
    And I should see the advocate categories 'Junior,Leading junior,KC'
    And I should see the scheme 17 applicable basic fees based on the govuk checkbox group
    And the basic fee net amount should be populated with '0.00'

    When I select an advocate category of 'Junior'
    Then the basic fee net amount should be populated with '696.00'

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
    When I click on misc fees helper text
    Then I should see the following miscellaneous fees listed:
      | Abuse of process hearings                             |
    # | Additional preparation fee                            |
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


    # Then I add a govuk calculated miscellaneous fee 'Additional preparation fee'
    And I add a govuk calculated miscellaneous fee 'Paper heavy case'
    And I add a govuk calculated miscellaneous fee 'Deferred sentence hearings'
    Then the following govuk fee details should exist:
      | section       | fee_description                  | rate   | hint            | help |
      #| miscellaneous | Additional preparation fee       | 81.00  | Number of fees  | true |
      | miscellaneous | Paper heavy case                 | 45.30  | Number of hours | true |
      | miscellaneous | Deferred sentence hearings       | 201.00 | Number of days  | true |

    And I eject the VCR cassette

    When I click "Continue" in the claim form
    Then I should be in the 'Travel expenses' form page
    
    When I click "Continue" in the claim form
    Then I should be in the 'Supporting evidence' form page
    Then I upload the document 'indictment.pdf'
    And I check the evidence boxes for 'Copy of the indictment'
    And I add some additional information

    When I click "Continue" in the claim form
    Then I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page
    
    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the claim confirmation page
    And I should see a page title "Thank you for submitting your claim"