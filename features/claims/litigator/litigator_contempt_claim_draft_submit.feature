@javascript
Feature: Litigator partially fills out a draft final fee claim, then later edits and submits it

  @fee_calc_vcr
  Scenario: I create a final fee claim, save it to draft and later complete it

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    Then the page should be accessible within "#content"
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator final fee'
    Then the page should be accessible within "#content"
    Then I should be on the litigator new claim page

    And I should see 3 supplier number radios

    When I choose the supplier number '1A222Z'
    And I select a case type of 'Contempt'
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20161234'
    And I enter the case concluded date '2016-04-01'
    Then the page should be accessible within "#content"
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    And 6+ supplier numbers exist for my provider
    Then Claim 'A20161234' should be listed with a status of 'Draft'

    When I click the claim 'A20161234'
    And I edit the claim's case details

    Then I should see a supplier number select list
    Then the page should be accessible within "#content"
    Then I click "Continue" in the claim form

    And I enter defendant, LGFS representation order and MAAT reference
    And I add another defendant, LGFS representation order and MAAT reference
    Then the page should be accessible within "#content"

    Given I insert the VCR cassette 'features/claims/litigator/fixed_fee_calculations'
    Then I click "Continue" in the claim form

    And I should see fixed fee type 'Contempt'
    And the fixed fee rate should be populated with '116.49'
    And I fill '2018-11-01' as the fixed fee date
    And I fill '2' as the fixed fee quantity
    Then I should see fixed fee total '£232.98'
    Then the page should be accessible within "#content"

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
    And I add an expense date for LGFS

    And I should see a page title "Enter travel expenses for litigator final fees claim"
    Then the page should be accessible within "#content"
    Then I click "Continue" in the claim form

    And I upload 1 document
    And I check the boxes for the uploaded documents
    And I add some additional information
    Then the page should be accessible within "#content"

    And I click Submit to LAA
    Then I should be on the check your claim page
    And I should see the field 'Crown court' with value 'Blackfriars' in 'Case details'
    And I should see the field 'Case type' with value 'Contempt' in 'Case details'
    And I should see the field 'Date case concluded' with value '01/04/2016' in 'Case details'
    And I should not see 'First day of trial'
    And I should not see 'Estimated trial length'
    And I should not see 'Actual trial length'
    And I should not see 'Trial concluded on'

    And I should see a page title "View claim summary for litigator final fees claim"
    Then the page should be accessible within "#content"
    When I click "Continue"
    Then I should be on the certification page

    And I should see a page title "Certify and submit the litigator final fees claim"
    Then the page should be accessible within "#content"
    And I click Certify and submit claim
    Then I should be on the claim confirmation page
    Then the page should be accessible within "#content"

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£754.71'
    Then the page should be accessible within "#content"
