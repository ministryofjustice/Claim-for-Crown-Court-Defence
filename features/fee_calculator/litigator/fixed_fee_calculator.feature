@javascript
Feature: litigator completes fixed fee page using calculator

  @fee_calc_vcr
  Scenario: I create a fixed fee claim using calculated value

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
    And I enter the case concluded date '2018-04-01'

    Then I click "Continue" in the claim form
    And I should be in the 'Defendant details' form page

    And I enter defendant, LGFS representation order and MAAT reference
    And I add another defendant, LGFS representation order and MAAT reference

    Given I insert the VCR cassette 'features/fee_calculator/litigator/fixed_fee_calculations'

    Then I click "Continue" in the claim form
    And I should be in the 'Fees' form page

    And I should see fixed fee type 'Appeals to the crown court against conviction'
    And the fixed fee rate should be populated with '349.47'
    And I fill '2018-11-01' as the fixed fee date
    And I fill '1' as the fixed fee quantity
    Then I should see fixed fee total '£349.47'
    And I fill '2' as the fixed fee quantity
    Then I should see fixed fee total '£698.94'

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page

    And I goto claim form step 'case details'
    And I select a case type of 'Hearing subsequent to sentence'
    Then I click "Continue" in the claim form

    And I goto claim form step 'fixed fees'
    Then the fixed fee rate should be populated with '155.32'
    Then I should see fixed fee total '£310.64'

    And I goto claim form step 'case details'
    And I select a case type of 'Elected cases not proceeded'
    Then I click "Continue" in the claim form

    And I goto claim form step 'fixed fees'
    Then the fixed fee rate should be populated with '330.33'
    Then I should see fixed fee total '£660.66'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
