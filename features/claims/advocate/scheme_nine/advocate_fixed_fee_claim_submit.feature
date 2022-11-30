@javascript
Feature: Advocate submits a claim for a Fixed fee (Appeal against sentence)

  @fee_calc_vcr
  Scenario: I create an Appeal against sentence claim, then submit it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Blackfriars'
    And I select a case type of 'Appeal against sentence'
    And I enter a case number of 'A20161234'
    And I enter scheme 9 main hearing date

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference
    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/claims/advocate/scheme_nine/fixed_fee_calculations'
    And I select an advocate category of 'Junior alone'

    Then the fixed fee checkboxes should consist of 'Appeals to the crown court against sentence,Number of cases uplift,Number of defendants uplift,Standard appearance fee,"Adjourned appeals, committals and breaches"'
    And I select the 'Appeals to the crown court against sentence' fixed fee
    Then the fixed fee 'Appeals to the crown court against sentence' should have a rate of '108.00' and a hint of 'Number of days'
    Then I click "Continue" in the claim form

    And I goto claim form step 'case details'
    And I select a case type of 'Appeal against conviction'
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I goto claim form step 'fixed fees'
    Then the fixed fee checkboxes should consist of 'Appeals to the crown court against conviction,Number of cases uplift,Number of defendants uplift,Standard appearance fee,"Adjourned appeals, committals and breaches"'
    And I select the 'Appeals to the crown court against conviction' fixed fee
    Then the fixed fee 'Appeals to the crown court against conviction' should have a rate of '130.00' and a hint of 'Number of days'
    And I select the 'Adjourned appeals, committals and breaches' fixed fee
    Then the fixed fee 'Adjourned appeals, committals and breaches' should have a rate of '87.00' and a hint of 'Number of days'
    And I select the 'Number of cases uplift' fixed fee with case numbers
    Then the fixed fee 'Number of cases uplift' should have a rate of '26.00'

    And I should see a page title "Enter fixed fees for advocate final fees claim"
    Then I click "Continue" in the claim form

    And I add a govuk calculated miscellaneous fee 'Special preparation fee' with dates attended
    Then the last 'miscellaneous' fee rate should be populated with '39.00'

    And I eject the VCR cassette

    And I should see a page title "Enter miscellaneous fees for advocate final fees claim"
    Then I click "Continue" in the claim form

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for scheme 9

    And I should see a page title "Enter travel expenses for advocate final fees claim"
    Then I click "Continue" in the claim form

    And I upload 3 documents
    And I check the boxes for the uploaded documents
    And I add some additional information

    And I should see a page title "Upload supporting evidence for advocate final fees claim"
    Then I click Submit to LAA
    And I should be on the check your claim page

    And I should see a page title "View claim summary for advocate final fees claim"
    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£379.87'
