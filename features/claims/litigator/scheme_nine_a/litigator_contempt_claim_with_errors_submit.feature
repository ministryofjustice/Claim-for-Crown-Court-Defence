@javascript
Feature: Litigator fills out a final fee claim, there is an error, fixes it and submits it

  @fee_calc_vcr
  Scenario: I create a final fee claim with an error, fixing it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    When I choose the supplier number '1A222Z'
    And I should see the London rates radios
    And I select 'Yes' to London rates
    And I select the court 'Blackfriars'
    And I select a case type of 'Contempt'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2022-10-01'
    And I enter lgfs scheme 9a main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, LGFS Scheme 9a representation order and MAAT reference
    And I add another defendant, LGFS Scheme 9a representation order and MAAT reference

    Given I insert the VCR cassette 'features/claims/litigator/fixed_fee_calculations'
    Then I click "Continue" in the claim form

    And I should see fixed fee type 'Contempt'
    And the fixed fee rate should be populated with '133.96'
    And I fill '2022-10-01' as the fixed fee date
    And I fill '2' as the fixed fee quantity
    Then I should see fixed fee total '267.92'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form

    And I should be in the 'Miscellaneous fees' form page
    Then I click "Continue" in the claim form

    And I should be in the 'Disbursements' form page
    Then I click "Continue" in the claim form

    And I should be in the 'Travel expenses' form page

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "99.25"
    And I add an expense vat amount for "15.50"
    And I add an expense date as invalid

    Then I should see in the sidebar total '£382.67'
    Then I should see in the sidebar vat total '£15.50'

    Then I click "Continue" in the claim form

    Then I should see govuk error summary with 'Enter a date for the first expense'
    Then I should see in the sidebar total '£382.67'
    Then I should see in the sidebar vat total '£15.50'

    And I enter the date for the first expense '2022-10-01'
    Then I click "Continue" in the claim form

    And I should be in the 'Supporting evidence' form page

    Then I click "Continue" in the claim form

    And I should be on the check your claim page
    When I click "Continue"
    Then I should be on the certification page
    And I click Certify and submit claim
    Then I should be on the claim confirmation page
