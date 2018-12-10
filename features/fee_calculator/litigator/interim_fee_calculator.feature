@javascript
Feature: litigator completes interim fee page using calculator

  @fee_calc_vcr
  Scenario: I create an LGFS "Trial" interim fee claim using calculated value

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator interim fee'
    Then I should be on the litigator new interim claim page

    And I click "Continue" in the claim form
    And I should be in the 'Case details' form page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS Trial interim fee calculation'
    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter a case number of 'A20161234'

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page

    And I enter defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I select the offence category 'Murder'
    Then the offence class list is set to 'A: Homicide and related grave offences'

    Given I insert the VCR cassette 'features/fee_calculator/litigator/interim_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Interim fee' form page

    Then I select an interim fee type of 'Effective PCMH'
    And the interim fee amount should be populated with '678.44'

    # PPE impact
    And I enter 80 in the PPE total field
    And the interim fee amount should be populated with '678.44'
    And I enter 81 in the PPE total field
    And the interim fee amount should be populated with '686.46'
    And I enter the effective PCMH date '2018-04-01'

    Then I click "Continue" in the claim form
    And I should be in the 'Evidence supplied on disk' form page

    # offence impact
    And I goto claim form step 'offence details'
    And I select the offence category 'Violent disorder'
    Then the offence class list is set to 'B: Offences involving serious violence or damage and serious drug offences'

    Then I click "Continue" in the claim form
    And I should be in the 'Interim fee' form page
    And the interim fee amount should be populated with '596.46'

    Then I click "Continue" in the claim form
    And I should be in the 'Evidence supplied on disk' form page

    # defendant uplift impact
    And I goto claim form step 'defendants'
    And I add another defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I goto claim form step 'interim fees'
    And the interim fee amount should be populated with '715.75'

    # Trial start scenario, 2 defendants, class B offence
    Then I select an interim fee type of 'Trial start'

    # PPE impact
    And I enter 70 in the PPE total field
    And the interim fee amount should be populated with '1317.19'
    And I enter 71 in the PPE total field
    And the interim fee amount should be populated with '1332.56'

    # Estimate trial length impact (first two days incl. 10 days minimum required)
    And I enter 2 in the estimated trial length field
    And the interim fee amount should be populated with '1332.56'
    And I enter 3 in the estimated trial length field
    And the interim fee amount should be populated with '1860.65'
    And I enter 10 in the estimated trial length field
    And the interim fee amount should be populated with '5204.77'
    And I enter the trial start date '2018-04-01'

    Then I click "Continue" in the claim form
    And I should be in the 'Evidence supplied on disk' form page

    And the interim fee should have its price_calculated value set to true

    And I eject the VCR cassette

  @fee_calc_vcr
  Scenario: I create an LGFS "Retrial" interim fee claim using calculated value

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator interim fee'
    Then I should be on the litigator new interim claim page

    And I click "Continue" in the claim form
    And I should be in the 'Case details' form page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS Retrial interim fee calculation'
    And I select the court 'Blackfriars'
    And I select a case type of 'Retrial'
    And I enter a case number of 'A20161234'

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page

    And I enter defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I select the offence category 'Murder'
    Then the offence class list is set to 'A: Homicide and related grave offences'

    Given I insert the VCR cassette 'features/fee_calculator/litigator/interim_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Interim fee' form page

    Then I select an interim fee type of 'Retrial New solicitor'
    And the interim fee amount should be populated with '452.29'

    # PPE impact
    And I enter 80 in the PPE total field
    And the interim fee amount should be populated with '452.29'
    And I enter 81 in the PPE total field
    And the interim fee amount should be populated with '457.64'
    And I enter the legal aid transfer date '2018-04-01'
    And I enter the first trial concluded date '2018-04-01'

    Then I click "Continue" in the claim form
    And I should be in the 'Evidence supplied on disk' form page

    # offence impact
    And I goto claim form step 'offence details'
    And I select the offence category 'Violent disorder'
    Then the offence class list is set to 'B: Offences involving serious violence or damage and serious drug offences'

    Then I click "Continue" in the claim form
    And I should be in the 'Interim fee' form page
    And the interim fee amount should be populated with '397.64'

    # defendant uplift impact
    And I goto claim form step 'defendants'
    And I add another defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I goto claim form step 'interim fees'
    And the interim fee amount should be populated with '477.17'

    # Retrial start scenario, 2 defendants, class B offence
    Then I select an interim fee type of 'Retrial start'

    # PPE impact
    And I enter 70 in the PPE total field
    And the interim fee amount should be populated with '1317.19'
    And I enter 71 in the PPE total field
    And the interim fee amount should be populated with '1332.56'

    # Estimated length of retrial impact (first two days incl. 10 days minimum required)
    And I enter 2 in the estimated retrial length field
    And the interim fee amount should be populated with '1332.56'
    And I enter 3 in the estimated retrial length field
    And the interim fee amount should be populated with '1860.65'
    And I enter 10 in the estimated retrial length field
    And the interim fee amount should be populated with '5204.77'
    And I enter the retrial start date '2018-04-01'

    Then I click "Continue" in the claim form
    And I should be in the 'Evidence supplied on disk' form page

    And the interim fee should have its price_calculated value set to true

    And I eject the VCR cassette
