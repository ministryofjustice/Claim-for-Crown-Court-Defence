@javascript
Feature: Advocate tries to submit a fee scheme 15 hardship claim for a trial with miscellaneous fees

  @fee_calc_vcr
  Scenario: I create a hardship claim for a trial

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate hardship fee'

    Then I should be on the advocate hardship new claim page
    And I should see a page title "Enter case details for advocate hardship fees claim"

    When I enter a providers reference of 'AGFS hardship claim test'
    And I select the court 'Caernarfon'
    And I enter a case number of 'A20201234'
    And I enter scheme 15 main hearing date

    When I select a case stage of 'After PTPH before trial'
    Then I should see hardship cracked trial fields

    When I select a case stage of 'Retrial listed but not started'
    Then I should see hardship cracked trial fields

    When I select a case stage of 'Trial started but not concluded'
    Then I should see trial fields

    And I enter scheme 15 trial start date
    And I enter an estimated trial length of 10

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I should see a page title "Enter defendant details for advocate hardship fees claim"

    And I enter defendant, scheme 15 representation order and MAAT reference
    And I add another defendant, scheme 15 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page
    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    Then I should see 'Band: 8.1'

    Given I insert the VCR cassette 'features/claims/advocate/scheme_fifteen/hardship_fee_calculations'

    When I select the first search result
    Then I should be in the 'Hardship fees' form page
    And I should see a page title "Enter graduated fees for advocate hardship fees claim"
    And I should see the advocate categories 'Junior,Leading junior,KC'
    And I should see the case stage 'Trial started but not concluded'
    And I should see the offence details 'Class : Offences Against the Public Interest, Band : 8.1, Category : Harbouring escaped prisoner'
    And I should see the scheme 15 applicable basic fees based on the govuk checkbox group

    When I select an advocate category of 'Junior'
    Then the basic fee net amount should be populated with '1392.00'
    And I select the govuk field 'Number of cases uplift' basic fee with quantity of 1 with case numbers

    When I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page
    And I should see a page title "Enter miscellaneous fees for advocate hardship fees claim"
    And I add a govuk calculated miscellaneous fee 'Special preparation fee' with quantity of '2'
    And I add a govuk calculated miscellaneous fee 'Ground rules hearing (whole day)' with quantity of '2'

    Then the following govuk fee details should exist:
      | section       | fee_description                  | rate   | hint            | help |
      | miscellaneous | Special preparation fee          | 45.30  | Number of hours | true |
      | miscellaneous | Ground rules hearing (whole day) | 276.00 | Number of days  | true |

    And I eject the VCR cassette

    Then I click "Continue" in the claim form and move to the 'Travel expenses' form page
    And I should see a page title "Enter travel expenses for advocate hardship fees claim"

    When I select an expense type "Parking"
    And I select a travel reason "Court hearing"
    And I add an expense date for scheme 15
    And I add an expense net amount for "34.56"

    When I click "Continue" in the claim form
    Then I should see a page title "Upload supporting evidence for advocate hardship fees claim"

    And I upload the document 'hardship.pdf'
    And I should see 10 evidence check boxes
    And I check the evidence boxes for 'Hardship supporting evidence'
    And I add some additional information

    When I click "Continue" in the claim form
    Then I should be on the check your claim page

    Then I should see a page title "View claim summary for advocate hardship fees claim"
    And the following check your claim details should exist:
      | section                 | prompt      | value                                |
      | case-details-section    | Crown court | Caernarfon                           |
      | case-details-section    | Case number | A20201234                            |
      | case-details-section    | Case stage  | Trial started but not concluded      |
      | offence-details-section | Class       | Offences Against the Public Interest |
      | offence-details-section | Band        | 8.1                                  |
      | offence-details-section | Category    | Harbouring escaped prisoner          |

    And I should not see 'Case type'

    And the following check your claim fee details should exist:
      | section            | row | prompt       | value                            |
      | basic-fees-section | 1   | Type of fee  | Basic fee                        |
      | basic-fees-section | 1   | Quantity     | 1                                |
      | basic-fees-section | 1   | Rate         | £1,392.00                        |
      | basic-fees-section | 1   | Net amount   | £1,392.00                        |
      | basic-fees-section | 1   | VAT amount   | £278.40                          |
      | basic-fees-section | 1   | Total amount | £1,670.40                        |
      | basic-fees-section | 2   | Type of fee  | Number of cases uplift T20170001 |
      | basic-fees-section | 2   | Quantity     | 1                                |
      | basic-fees-section | 2   | Rate         | £278.40                          |
      | basic-fees-section | 2   | Net amount   | £278.40                          |
      | basic-fees-section | 2   | VAT amount   | £55.68                           |
      | basic-fees-section | 2   | Total amount | £334.08                          |

    And the following check your claim fee details should exist:
      | section                    | row | prompt      | value                            |
      | miscellaneous-fees-section | 1   | Type of fee | Special preparation fee          |
      | miscellaneous-fees-section | 1   | Quantity    | 2                                |
      | miscellaneous-fees-section | 1   | Rate        | 45.30                            |
      | miscellaneous-fees-section | 1   | Net amount  | 90.60                            |
      | miscellaneous-fees-section | 2   | Type of fee | Ground rules hearing (whole day) |
      | miscellaneous-fees-section | 2   | Quantity    | 2                                |
      | miscellaneous-fees-section | 2   | Rate        | 276.00                           |
      | miscellaneous-fees-section | 2   | Net amount  | 552.00                           |

    Then the following check your claim details should exist:
      | section                     | prompt                        | value                        |
      | supporting-evidence-section | Supporting evidence           | hardship.pdf                 |
      | supporting-evidence-section | Supporting evidence checklist | Hardship supporting evidence |

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”

    And I should see a page title "Certify and submit the advocate hardship fees claim"
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    And I should see a page title "Thank you for submitting your claim"
    When I click View your claims
    Then I should be on the your claims page

    And Claim 'A20201234' should be listed with a status of 'Submitted' and a claimed amount of '£2,817.07'
    When I click the link 'A20201234'
    Then I should be in the providers claim summary page
    And I should see 'Case stage'
    And I should not see 'Case type'

