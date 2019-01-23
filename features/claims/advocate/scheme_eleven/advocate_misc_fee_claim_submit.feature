@javascript
Feature: Advocate tries to submit a claim for a Miscellaneous fee (only)

  @fee_calc_vcr
  Scenario: I create a Trial claim but skip the graduated/basic fees, adding only applicable misc fees

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate miscellaneous fee'
    Then I should be on the new claim page

    And I select the court 'Caernarfon'
    And I select a case type of 'Trial'
    And I enter a case number of 'A20191234'
    And I enter scheme 11 trial start and end dates

    Then I click "Continue" in the claim form

    And I enter defendant, scheme 11 representation order and MAAT reference
    And I add another defendant, scheme 11 representation order and MAAT reference

    Given I insert the VCR cassette 'features/claims/advocate/scheme_eleven/misc_fee_calculations'

    When I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page

    # what to do with advocate categories for misc-fee-only
    And I should see the advocate categories 'Junior,Leading junior,QC'
    And I should see eligible miscellaneous fees
    And I select an advocate category of 'Junior'

    # When I add a calculated miscellaneous fee 'Special preparation fee' with dates attended '2019-01-01'
    # And I add a calculated miscellaneous fee 'Wasted preparation fee' with dates attended '2019-01-01'
    # And I add a calculated miscellaneous fee 'Confiscation hearings (half day)'
    # And I add a calculated miscellaneous fee 'Confiscation hearings (half day uplift)'
    # And I add a calculated miscellaneous fee 'Confiscation hearings (whole day)'
    # And I add a calculated miscellaneous fee 'Confiscation hearings (whole day uplift)'


    And I eject the VCR cassette
