@javascript
Feature: Advocate tries to submit a fee scheme 13 supplementary claim for miscellaneous fees (only)

  @fee_calc_vcr
  Scenario: I create a supplementary claim but skip adding only applicable misc fees

    Given the current date is '2022-10-30'
    And I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate supplementary fee'

    Then I should be on the advocate supplementary new claim page

    When I enter a providers reference of 'AGFS supplementary fee test'
    And I select the court 'Caernarfon'
    And I enter a case number of 'A20191234'
    And I enter scheme 13 main hearing date

    And I should see a page title "Enter case details for advocate supplementary fee claim"
    Then I click "Continue" in the claim form

    And I enter defendant, scheme 13 representation order and MAAT reference
    And I add another defendant, scheme 13 representation order and MAAT reference

    Given I insert the VCR cassette 'features/claims/advocate/scheme_thirteen/supplementary_fee_calculations'

    And I should see a page title "Enter defendant details for advocate supplementary fee claim"
    When I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page
    And I should see the advocate categories 'Junior,Leading junior,QC'
    And the following miscellaneous fee checkboxes should exist:
      | section       | fee_description                          |
      | miscellaneous | Confiscation hearings (half day)         |
      | miscellaneous | Confiscation hearings (half day uplift)  |
      | miscellaneous | Confiscation hearings (whole day)        |
      | miscellaneous | Confiscation hearings (whole day uplift) |
      | miscellaneous | Deferred sentence hearings               |
      | miscellaneous | Deferred sentence hearings uplift        |
      | miscellaneous | Further case management hearing          |
      | miscellaneous | Paper heavy case                         |
      | miscellaneous | Plea and trial preparation hearing       |
      | miscellaneous | Sentence hearings                        |
      | miscellaneous | Sentence hearings uplift                 |
      | miscellaneous | Special preparation fee                  |
      | miscellaneous | Standard appearance fee                  |
      | miscellaneous | Standard appearance fee uplift           |
      | miscellaneous | Unused materials (over 3 hours)          |
      | miscellaneous | Unused materials (up to 3 hours)         |
      | miscellaneous | Wasted preparation fee                   |

    When I select an advocate category of 'Junior'
    And I choose the 'Confiscation hearings (half day)' miscellaneous fee with quantity of '2'
    And I choose the 'Confiscation hearings (half day uplift)' miscellaneous fee with quantity of '1'
    And I choose the 'Standard appearance fee' miscellaneous fee with quantity of '2'
    And I choose the 'Standard appearance fee uplift' miscellaneous fee with quantity of '1'
    And I choose the 'Wasted preparation fee' miscellaneous fee with quantity of '1'

    Then the following supplementary fee details should exist:
      | section       | fee_description                         | rate   | hint                            | help |
      | miscellaneous | Confiscation hearings (half day)        | 151.00 | Number of half days             | true |
      | miscellaneous | Confiscation hearings (half day uplift) | 60.40  | Number of additional defendants | true |
      | miscellaneous | Standard appearance fee                 | 105.00 | Number of days                  | true |
      | miscellaneous | Standard appearance fee uplift          | 42.00  | Number of additional defendants | true |
      | miscellaneous | Wasted preparation fee                  | 45.30  | Number of hours                 | true |

    And I eject the VCR cassette

    And I should see a page title "Enter miscellaneous fees for advocate supplementary fee claim"
    When I click "Continue" in the claim form
    Then I should be in the 'Travel expenses' form page

    And I select an expense type "Parking"
    And I select a travel reason "Court hearing"
    And I add an expense date for scheme 13
    And I add an expense net amount for "34.56"

    And I should see a page title "Enter travel expenses for advocate supplementary fee claim"
    Then I click "Continue" in the claim form

    When I upload the document 'judicial_appointment_order.pdf'
    And I should see 10 evidence check boxes
    And I check the evidence boxes for 'Order in respect of judicial apportionment'
    And I add some additional information

    And I should see a page title "Upload supporting evidence for advocate msupplementary fee claim"
    When I click "Continue" in the claim form
    And I should be on the check your claim page

    Then I should see a page title "View claim summary for advocate supplementary fee claim"
    And the following check your claim details should exist:
      | section              | prompt      | value      |
      | case-details-section | Crown court | Caernarfon |
      | case-details-section | Case number | A20191234  |

    And I should not see 'Case type'

    And the following check your claim fee details should exist:
      | section                    | row | prompt      | value                                   |
      | miscellaneous-fees-section | 1   | Type of fee | Confiscation hearings (half day)        |
      | miscellaneous-fees-section | 1   | Quantity    | 2                                       |
      | miscellaneous-fees-section | 1   | Rate        | 151.00                                  |
      | miscellaneous-fees-section | 1   | Net amount  | 302.00                                  |
      | miscellaneous-fees-section | 2   | Type of fee | Confiscation hearings (half day uplift) |
      | miscellaneous-fees-section | 2   | Quantity    | 1                                       |
      | miscellaneous-fees-section | 2   | Rate        | 60.40                                   |
      | miscellaneous-fees-section | 2   | Net amount  | 60.40                                   |
      | miscellaneous-fees-section | 3   | Type of fee | Standard appearance fee uplift          |
      | miscellaneous-fees-section | 3   | Quantity    | 1                                       |
      | miscellaneous-fees-section | 3   | Rate        | 42.00                                   |
      | miscellaneous-fees-section | 3   | Net amount  | 42.00                                   |
      | miscellaneous-fees-section | 4   | Type of fee | Wasted preparation fee                  |
      | miscellaneous-fees-section | 4   | Quantity    | 1                                       |
      | miscellaneous-fees-section | 4   | Rate        | 45.30                                   |
      | miscellaneous-fees-section | 4   | Net amount  | 45.30                                   |
      | miscellaneous-fees-section | 5   | Type of fee | Standard appearance fee                 |
      | miscellaneous-fees-section | 5   | Quantity    | 2                                       |
      | miscellaneous-fees-section | 5   | Rate        | 105.00                                  |
      | miscellaneous-fees-section | 5   | Net amount  | 210.00                                  |

    And I should not see 'Offence details'

    Then the following check your claim details should exist:
      | section                     | prompt                        | value                                      |
      | supporting-evidence-section | Supporting evidence           | judicial_appointment_order.pdf             |
      | supporting-evidence-section | Supporting evidence checklist | Order in respect of judicial apportionment |

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”

    And I should see a page title "Certify and submit the advocate supplementary fees claim"
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    And I should see a page title "Thank you for submitting your claim"
    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20191234' should be listed with a status of 'Submitted' and a claimed amount of '£833.11'
