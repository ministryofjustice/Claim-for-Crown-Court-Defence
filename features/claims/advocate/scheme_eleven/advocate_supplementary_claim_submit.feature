@javascript
Feature: Advocate tries to submit a supplementary claim for miscellaneous fees (only)

  @fee_calc_vcr
  Scenario: I create a supplementary claim but skip adding only applicable misc fees

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate supplementary fee'
    Then I should be on the advocate supplementary new claim page

    When I enter a providers reference of 'AGFS supplementary fee test'
    And I select the court 'Caernarfon'
    And I enter a case number of 'A20191234'

    Then I click "Continue" in the claim form

    And I enter defendant, scheme 11 representation order and MAAT reference
    And I add another defendant, scheme 11 representation order and MAAT reference

    Given I insert the VCR cassette 'features/claims/advocate/scheme_eleven/supplementary_fee_calculations'

    When I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page
    And I should see the advocate categories 'Junior,Leading junior,QC'

    When I select an advocate category of 'Junior'
    And I choose the 'Wasted preparation fee' miscellaneous fee with quantity of '1'
    And I choose the 'Confiscation hearings (half day)' miscellaneous fee with quantity of '2'
    And I choose the 'Confiscation hearings (half day uplift)' miscellaneous fee with quantity of '1'

    Then the following supplementary fee details should exist:
      | section | fee_description | rate | hint | help |
      | miscellaneous | Wasted preparation fee | 39.39 | Number of hours | true |
      | miscellaneous | Confiscation hearings (half day) | 131.00 | Number of half days | true |
      | miscellaneous | Confiscation hearings (half day uplift) | 52.40 | Number of additional defendants | true |

    And I eject the VCR cassette

    When I click "Continue" in the claim form
    Then I should be in the 'Travel expenses' form page

    And I select an expense type "Parking"
    And I select a travel reason "Court hearing"
    And I add an expense date for scheme 11
    And I add an expense net amount for "34.56"

    Then I click "Continue" in the claim form

    When I upload the document 'judicial_appointment_order.pdf'
    And I should see 10 evidence check boxes
    And I check the evidence boxes for 'Order in respect of judicial apportionment'
    And I add some additional information

    When I click "Continue" in the claim form
    And I should be on the check your claim page
    Then the following check your claim details should exist:
      | section | prompt | value |
      | case-details-section | Crown court | Caernarfon |
      | case-details-section | Case number | A20191234 |

    And I should not see 'Case type'

    And the following check your claim fee details should exist:
      | section | row | prompt | value |
      | miscellaneous-fees-section | 1 | Type of fee | Confiscation hearings (half day) |
      | miscellaneous-fees-section | 1 | Quantity | 2 |
      | miscellaneous-fees-section | 1 | Rate | 131.00 |
      | miscellaneous-fees-section | 1 | Net amount | 262.00 |
      | miscellaneous-fees-section | 2 | Type of fee | Confiscation hearings (half day uplift) |
      | miscellaneous-fees-section | 2 | Quantity | 1 |
      | miscellaneous-fees-section | 2 | Rate | 52.40 |
      | miscellaneous-fees-section | 2 | Net amount | 52.40 |
      | miscellaneous-fees-section | 3 | Type of fee | Wasted preparation fee |
      | miscellaneous-fees-section | 3 | Quantity | 1 |
      | miscellaneous-fees-section | 3 | Rate | 39.39 |
      | miscellaneous-fees-section | 3 | Net amount | 39.39 |

    And I should not see 'Offence details'

    Then the following check your claim details should exist:
      | section | prompt | value |
      | supporting-evidence-section | Supporting evidence | judicial_appointment_order.pdf |
      | supporting-evidence-section | Supporting evidence checklist | Order in respect of judicial apportionment |

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20191234' should be listed with a status of 'Submitted' and a claimed amount of '£466.02'
