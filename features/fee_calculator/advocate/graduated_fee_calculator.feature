@javascript
Feature: Advocate completes graduated (a.k.a basic) fee page using calculator

  @fee_calc_vcr
  Scenario: I create a scheme 9 AGFS graduated fee claim using calculated value

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I enter a providers reference of 'AGFS test graduated fee calculation'
    And I select a case type of 'Trial'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter trial start and end dates

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page

    And I enter defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I select the offence category 'Murder'

    Given I insert the VCR cassette 'features/fee_calculator/advocate/graduated_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Fees' form page

    And the basic fee net amount should be populated with '0.00'

    # advocate category impacts "basic" fee
    Then I select an advocate category of 'Junior alone'
    And the basic fee net amount should be populated with '1632.00'
    Then I select an advocate category of 'QC'
    And the basic fee net amount should be populated with '2856.00'

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    # offence impact on "basic" fee
    And I goto claim form step 'offence details'
    And I select the offence category 'Activities relating to opium'

    Then I click "Continue" in the claim form
    And the basic fee net amount should be populated with '2529.00'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
