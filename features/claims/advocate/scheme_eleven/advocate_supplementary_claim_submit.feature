@javascript
Feature: Advocate tries to submit a claim for a Miscellaneous fee (only)

  @fee_calc_vcr
  Scenario: I create a Trial claim but skip the graduated/basic fees, adding only applicable misc fees

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate supplementary fee'
    Then I should be on the advocate supplementary new claim page

    And I select the court 'Caernarfon'
    And I select a case type of 'Trial'
    And I enter a case number of 'A20191234'
    And I enter scheme 11 trial start and end dates

    Then I click "Continue" in the claim form

    And I enter defendant, scheme 11 representation order and MAAT reference
    And I add another defendant, scheme 11 representation order and MAAT reference

    Given I insert the VCR cassette 'features/claims/advocate/scheme_eleven/supplementary_fee_calculations'

    When I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page
    And I should see the advocate categories 'Junior,Leading junior,QC'

    When I select an advocate category of 'Junior'
    And I add a calculated miscellaneous fee 'Wasted preparation fee'
    And I add a calculated miscellaneous fee 'Confiscation hearings (half day)' with quantity of '2'
    And I add a calculated miscellaneous fee 'Confiscation hearings (half day uplift)' with quantity of '1'
    Then the following fee details should exist:
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

    # When I click "Continue"
    # Then I should be on the certification page

    # When I check “I attended the main hearing”
    # And I click Certify and submit claim
    # Then I should be on the page showing basic claim information

    # Then I should be on the check your claim page
    # And I should see 'Blackfriars'
    # And I should see 'A20161234'
    # And I should see 'Trial'

    # And I should see 'Activities relating to opium'
    # And I should see 'B: Offences involving serious violence or damage and serious drug offences'
    # And I should see 'Junior alone'

    # And I should see 'Basic fee'
    # And I should see 'Number of cases uplift'
    # And I should see 'Special preparation fee'
    # And I should see 'Noting brief fee'
    # And I should see 'Hotel accommodation'

    # And I should see 'judicial_appointment_order.pdf'
    # And I should see 'Order in respect of judicial apportionment'
    # And I should see 'Bish bosh bash'

    # When I click View your claims
    # Then I should be on the your claims page
    # And Claim 'A20191234' should be listed with a status of 'Submitted' and a claimed amount of '£2,023.87'
