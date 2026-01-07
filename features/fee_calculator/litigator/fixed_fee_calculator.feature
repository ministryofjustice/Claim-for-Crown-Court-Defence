@javascript
@fee_calc_vcr
Feature: litigator completes fixed fee page using calculator

  Scenario: I create a fee scheme 9 fixed fee claim using calculated value

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS test fixed fee calculation'
    And I select a case type of 'Appeal against conviction'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2022-09-29'

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, LGFS representation order and MAAT reference
    And I add another defendant, LGFS representation order and MAAT reference

    Given I insert the VCR cassette 'features/fee_calculator/litigator/fixed_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Fixed fees' form page

    And the fixed fee rate should be populated with '349.47'
    And I fill '2022-09-29' as the fixed fee date
    And I fill '1' as the fixed fee quantity
    Then I should see fixed fee total '£349.47'
    And I fill '2' as the fixed fee quantity
    Then I should see fixed fee total '£698.94'

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And I goto claim form step 'case details'
    And I select a case type of 'Hearing subsequent to sentence'
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I goto claim form step 'fixed fees'
    Then the fixed fee rate should be populated with '155.32'
    Then I should see fixed fee total '£310.64'

    And I goto claim form step 'case details'
    And I select a case type of 'Elected cases not proceeded'
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I goto claim form step 'fixed fees'
    Then the fixed fee rate should be populated with '330.33'
    Then I should see fixed fee total '£660.66'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And the fixed fee should have its price_calculated value set to true

  Scenario: I create a fee scheme 10 fixed fee claim using calculated value

    Given  the current date is '2022-10-30'
    And I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS test fixed fee calculation'
    And I select a case type of 'Appeal against conviction'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2022-10-29'

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, LGFS Scheme 10 representation order and MAAT reference
    And I add another defendant, LGFS Scheme 10 representation order and MAAT reference

    Given I insert the VCR cassette 'features/fee_calculator/litigator/fixed_fee_calculator'

    Then I click "Continue" in the claim form
    And I should be in the 'Fixed fees' form page

    And the fixed fee rate should be populated with '401.89'
    And I fill '2022-10-01' as the fixed fee date
    And I fill '1' as the fixed fee quantity
    Then I should see fixed fee total '£401.89'
    And I fill '2' as the fixed fee quantity
    Then I should see fixed fee total '£803.78'

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And I goto claim form step 'case details'
    And I select a case type of 'Hearing subsequent to sentence'
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I goto claim form step 'fixed fees'
    Then the fixed fee rate should be populated with '178.62'
    Then I should see fixed fee total '£357.24'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And the fixed fee should have its price_calculated value set to true

  Scenario: I attempt to create a post-CLAIR elected cases not proceeded claim

    Given the current date is '2022-10-30'
    And I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page
    And I should see 'You should not select elected cases not proceeded if'
    And I should see 'The representation order is dated on or after 30 September 2022'
    And I should see 'The representation order is dated on or after 17 September 2020 with a main hearing date on or after 31 October 2022.'
    And I should see 'For these claims, select guilty plea or cracked trial.'

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS test fixed fee calculation'
    And I select a case type of 'Elected cases not proceeded'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2022-10-29'

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, lgfs scheme 10 representation order and MAAT reference

    Then I click "Continue" in the claim form
    And I should see govuk error summary with 'The representation order date, main hearing date and case type cannot be combined'
