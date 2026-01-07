@javascript
@fee_calc_vcr
Feature: litigator completes graduated fee page using calculator

  Scenario: I create a fee scheme 9 graduated fee claim using calculated value

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
    And I enter the case concluded date '2022-09-29'

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I select the offence category 'Abandonment of children under two'
    Then the offence class list is set to 'C: Lesser offences involving violence or damage and less serious drug offences'

    Given I insert the VCR cassette 'features/fee_calculator/litigator/graduated_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Graduated fee' form page
    And the graduated fee amount should be populated with '442.91'

    And I fill '2022-09-29' as the graduated fee date

    # ppe impact for guilty plea
    And I enter '41' in the PPE total graduated fee field
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

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I goto claim form step 'graduated fees'
    And the graduated fee amount should be populated with '0.00'
    And I fill '2022-09-29' as the graduated fee date

    # trial length (days) impact for trials
    When I fill '2' as the actual trial length
    Then the graduated fee amount should be populated with '1467.58'
    When I fill '3' as the actual trial length
    Then the graduated fee amount should be populated with '1720.12'

    # ppe impact for trials (boundary 96 plus for 3 day trial)
    When I enter '96' in the PPE total graduated fee field
    Then the graduated fee amount should be populated with '1732.86'

    Then I click "Continue" in the claim form

    # defendant uplift impact
    And I goto claim form step 'defendants'
    And I add another defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I goto claim form step 'graduated fees'
    And the graduated fee amount should be populated with '2079.43'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And the graduated fee should have its price_calculated value set to true

  Scenario: I create a fee scheme 10 graduated fee claim using calculated value

    Given the current date is '2022-10-30'
    And I am a signed in litigator
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
    And I enter the case concluded date '2022-10-29'

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, LGFS Scheme 10 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I select the offence category 'Abandonment of children under two'
    Then the offence class list is set to 'C: Lesser offences involving violence or damage and less serious drug offences'

    Given I insert the VCR cassette 'features/fee_calculator/litigator/graduated_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Graduated fee' form page
    And the graduated fee amount should be populated with '509.35'

    And I fill '2022-10-01' as the graduated fee date

    # ppe impact for guilty plea
    And I enter '41' in the PPE total graduated fee field
    And the graduated fee amount should be populated with '512.01'

    # offence impact
    And I goto claim form step 'offence details'
    And I select the offence category 'Murder'
    Then the offence class list is set to 'A: Homicide and related grave offences'

    Then I click "Continue" in the claim form
    And I should be in the 'Graduated fee' form page
    And the graduated fee amount should be populated with '782.45'

    # case type impact
    And I goto claim form step 'case details'
    And I select a case type of 'Trial'

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I goto claim form step 'graduated fees'
    And the graduated fee amount should be populated with '0.00'
    And I fill '2022-10-01' as the graduated fee date

    # trial length (days) impact for trials
    When I fill '2' as the actual trial length
    Then the graduated fee amount should be populated with '1687.72'
    When I fill '3' as the actual trial length
    Then the graduated fee amount should be populated with '1940.26'

    # ppe impact for trials (boundary 96 plus for 3 day trial)
    When I enter '96' in the PPE total graduated fee field
    Then the graduated fee amount should be populated with '1940.26'

    Then I click "Continue" in the claim form

    # defendant uplift impact
    And I goto claim form step 'defendants'
    And I add another defendant, LGFS Scheme 10 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I goto claim form step 'graduated fees'
    And the graduated fee amount should be populated with '2343.60'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And the graduated fee should have its price_calculated value set to true
