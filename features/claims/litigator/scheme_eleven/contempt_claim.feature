@javascript
Feature: Litigator partially fills out a draft final fee claim, then later edits and submits it

  @fee_calc_vcr
  Scenario: I create a final fee claim, save it to draft and later complete it

    Given the current date is '2026-03-03'
    And I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then I should be on the litigator new claim page

    And I should see 3 supplier number radios

    When I choose the supplier number '1A222Z'
    And I select a case type of 'Contempt'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2026-03-03'
    And I enter lgfs scheme 11 main hearing date
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I enter defendant, LGFS Scheme 11 representation order and MAAT reference
    And I add another defendant, LGFS Scheme 11 representation order and MAAT reference

    Given I insert the VCR cassette 'features/claims/litigator/fixed_fee_calculations'
    Then I click "Continue" in the claim form

    And I should see fixed fee type 'Contempt'
    And the fixed fee rate should be populated with '133.96'
    And I fill '2026-03-03' as the fixed fee date
    And I fill '2' as the fixed fee quantity
    Then I should see fixed fee total '267.92'

    And I eject the VCR cassette

    And I should see a page title "Enter fixed fees for litigator final fees claim"
    Then I click "Continue" in the claim form

    And I should be in the 'Miscellaneous fees' form page
    And the first miscellaneous fee should have fee types 'Costs judge application,Costs judge preparation,Defendant uplift,Evidence provision fee,Special preparation fee'
    And I add a litigator miscellaneous fee 'Costs judge application'
    And I add a litigator miscellaneous fee 'Defendant uplift'

    And I should see a page title "Enter miscellaneous fees for litigator final fees claim"
    Then I click "Continue" in the claim form

    And I add a disbursement 'Computer experts' with net amount '125.40' and vat amount '25.08'
    And I add another disbursement 'Meteorologist' with net amount '58.22' and vat amount '0'

    And I should see a page title "Enter disbursements for litigator final fees claim"
    Then I click "Continue" in the claim form and move to the 'Travel expenses' form page

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for LGFS Scheme 11

    And I should see a page title "Enter travel expenses for litigator final fees claim"
    Then I click "Continue" in the claim form

    And I upload 1 document
    And I check the boxes for the uploaded documents
    And I add some additional information

    And I click Submit to LAA
    Then I should be on the check your claim page
    And I should see the field 'Crown court' with value 'Blackfriars' in 'Case details'
    And I should see the field 'Case type' with value 'Contempt' in 'Case details'
    And I should see the field 'Date case concluded' with value '03/03/2026' in 'Case details'
    And I should not see 'First day of trial'
    And I should not see 'Estimated trial length'
    And I should not see 'Actual trial length'
    And I should not see 'Trial concluded on'

    And I should see a page title "View claim summary for litigator final fees claim"
    When I click "Continue"
    Then I should be on the certification page

    And I should see a page title "Certify and submit the litigator final fees claim"
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£789.65'
