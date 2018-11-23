@javascript
Feature: litigator completes graduated fee page using calculator

  @fee_calc_vcr
  Scenario: I create a graduated fee claim using calculated value

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS test graduated fee calculation'
    And I select a case type of 'Guilty plea'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2018-04-01'

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page

    And I enter defendant, LGFS representation order and MAAT reference
    And I add another defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I select the offence category 'Abandonment of children under two'
    Then the offence class list is set to 'C: Lesser offences involving violence or damage and less serious drug offences'

    Given I insert the VCR cassette 'features/fee_calculator/litigator/graduated_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Graduated fee' form page
    And the graduated fee amount should be populated with '442.91'

     # trial length (days) has no impact on guilty plea
    And I fill '2018-01-01' as the graduated fee date
    And I fill '100000' as the actual trial length
    And the graduated fee amount should be populated with '442.91'
    And I fill '0' as the actual trial length
    And the graduated fee amount should be populated with '442.91'

    # ppe impact for guilty plea
    And I fill '40' as the ppe total
    And the graduated fee amount should be populated with '442.91'
    And I fill '41' as the ppe total
    And the graduated fee amount should be populated with '445.57'

    # offence impact
    And I goto claim form step 'offence details'
    And I select the offence category 'Murder'
    Then the offence class list is set to 'A: Homicide and related grave offences'

    Then I click "Continue" in the claim form
    And I should be in the 'Graduated fee' form page
    And the graduated fee amount should be populated with '680.39'

    # case type impact
    And I goto claim form step 'case details'
    And I select a case type of 'Trial'

    Then I click "Continue" in the claim form
    And I goto claim form step 'graduated fees'
    And the graduated fee amount should be populated with '1467.58'

    # trial length (days) impact for trials
    And I fill '2018-01-01' as the graduated fee date
    And I fill '2' as the actual trial length
    And the graduated fee amount should be populated with '1467.58'
    And I fill '3' as the actual trial length
    And the graduated fee amount should be populated with '1720.12'

    # ppe impact for trials
    And I fill '95' as the ppe total
    And the graduated fee amount should be populated with '1720.12'
    And I fill '96' as the ppe total
    And the graduated fee amount should be populated with '1732.86'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And the graduated fee should have its price_calculated value set to true
