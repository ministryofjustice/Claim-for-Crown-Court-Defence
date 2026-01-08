@javascript
@fee_calc_vcr
Feature: litigator completes transfer fee page using calculator

  Scenario: I create a scheme 9 graduated fee claim using calculated value

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator transfer fee'
    Then I should be on the litigator new transfer claim page

    When I choose the litigator type option 'New'
    And I choose the elected case option 'No'
    And I select the transfer stage 'During trial transfer'
    And I enter the transfer date '2022-09-29'
    And I select a case conclusion of 'Trial'

    And I click "Continue" in the claim form

    When I choose the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date

    And I click "Continue" in the claim form

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page

    And I enter defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I select the offence category 'Murder'
    Then the offence class list is set to 'A: Homicide and related grave offences'

    Given I insert the VCR cassette 'features/fee_calculator/litigator/transfer_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Transfer details' form page
    And I should see the days claimed field
    And I should see the ppe field
    And the transfer fee amount should be populated with '0.00'

    # trial length (days) trial - first two days included
    When I fill '2' as the actual trial length
    Then the transfer fee amount should be populated with '733.79'
    When I fill '3' as the actual trial length
    Then the transfer fee amount should be populated with '860.06'

    # ppe impact for 3 day claimed trial (first 95 pages included)
    When I enter '96' in the PPE total graduated fee field
    Then the transfer fee amount should be populated with '866.43'

    # offence impact
    And I goto claim form step 'offence details'
    And I select the offence category 'Abandonment of children under two'
    Then the offence class list is set to 'C: Lesser offences involving violence or damage and less serious drug offences'

    Then I click "Continue" in the claim form
    And I should be in the 'Transfer details' form page
    When I fill '2' as the actual trial length
    Then the transfer fee amount should be populated with '369.80'

    # transfer details impact
    And I goto claim form step 'transfer fee details'

    And I choose the litigator type option 'New'
    And I choose the elected case option 'No'
    And I select the transfer stage 'Up to and including PCMH transfer'
    And I select a case conclusion of 'Guilty plea'

    Then I click "Continue" in the claim form
    And I goto claim form step 'transfer fees'

    # trial length (days) - no impact for guilty plea
    Then I should not see the days claimed field
    And I should see the ppe field
    And the transfer fee amount should be populated with '442.91'

    # ppe impact for guilty plea
    When I enter '41' in the PPE total graduated fee field
    Then the transfer fee amount should be populated with '445.57'

    # defendant uplift impact
    And I goto claim form step 'defendants'
    And I add another defendant, LGFS representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I goto claim form step 'transfer fees'
    Then the transfer fee amount should be populated with '531.49'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And the transfer fee should have its price_calculated value set to true

  Scenario: I create a scheme 10 graduated fee claim using calculated value

    Given the current date is '2022-10-30'
    And I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator transfer fee'
    Then I should be on the litigator new transfer claim page

    When I choose the litigator type option 'New'
    And I choose the elected case option 'No'
    And I select the transfer stage 'During trial transfer'
    And I enter the transfer date '2022-10-01'
    And I select a case conclusion of 'Trial'

    And I click "Continue" in the claim form

    When I choose the supplier number '1A222Z'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2022-10-29'

    And I click "Continue" in the claim form

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page

    And I enter defendant, LGFS Scheme 10 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I select the offence category 'Murder'
    Then the offence class list is set to 'A: Homicide and related grave offences'

    Given I insert the VCR cassette 'features/fee_calculator/litigator/transfer_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Transfer details' form page
    And I should see the days claimed field
    And I should see the ppe field
    And the transfer fee amount should be populated with '0.00'

    # trial length (days) trial - first two days included
    When I fill '2' as the actual trial length
    Then the transfer fee amount should be populated with '843.86'
    When I fill '3' as the actual trial length
    Then the transfer fee amount should be populated with '970.13'

    # ppe impact for 3 day claimed trial (first 95 pages included)
    When I enter '96' in the PPE total graduated fee field
    Then the transfer fee amount should be populated with '976.50'

    # offence impact
    And I goto claim form step 'offence details'
    And I select the offence category 'Abandonment of children under two'
    Then the offence class list is set to 'C: Lesser offences involving violence or damage and less serious drug offences'

    Then I click "Continue" in the claim form
    And I should be in the 'Transfer details' form page
    When I fill '2' as the actual trial length
    Then the transfer fee amount should be populated with '425.26'

    # transfer details impact
    And I goto claim form step 'transfer fee details'

    And I choose the litigator type option 'New'
    And I choose the elected case option 'No'
    And I select the transfer stage 'Up to and including PCMH transfer'
    And I select a case conclusion of 'Guilty plea'

    Then I click "Continue" in the claim form
    And I goto claim form step 'transfer fees'

    # trial length (days) - no impact for guilty plea
    Then I should not see the days claimed field
    And I should see the ppe field
    And the transfer fee amount should be populated with '509.35'

    # ppe impact for guilty plea
    When I enter '41' in the PPE total graduated fee field
    Then the transfer fee amount should be populated with '512.01'

    # defendant uplift impact
    And I goto claim form step 'defendants'
    And I add another defendant, LGFS Scheme 10 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I goto claim form step 'transfer fees'
    Then the transfer fee amount should be populated with '611.22'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And the transfer fee should have its price_calculated value set to true
