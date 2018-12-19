@javascript
Feature: Advocate submits a claim for a Fixed fee (Appeal against conviction)

  @fee_calc_vcr
  Scenario: I create an Appeal against conviction claim, then submit it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Caernarfon'
    And I select a case type of 'Appeal against conviction'
    And I enter a case number of 'A20181234'

    Then I click "Continue" in the claim form

    And I enter defendant, scheme 10 representation order and MAAT reference
    And I add another defendant, scheme 10 representation order and MAAT reference

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/claims/advocate/scheme_ten/fixed_fee_calculations' and record 'new_episodes'

    And I should see the advocate categories 'Junior,Leading junior,QC'
    And I select an advocate category of 'Junior'
    Then the fixed fee checkboxes should consist of 'Appeals to the crown court against conviction,Number of cases uplift,Number of defendants uplift,Standard appearance fee,"Adjourned appeals, committals and breaches"'

    And I select the 'Appeals to the crown court against conviction' fixed fee
    Then the fixed fee 'Appeals to the crown court against conviction' should have a rate of '250.00' and a hint of 'Number of days'
    And I add a 'Number of cases uplift' fixed fee with case numbers
    Then the fixed fee 'Number of cases uplift' should have a rate of '50.00'
    And I select the 'Standard appearance fee' fixed fee
    Then the fixed fee 'Standard appearance fee' should have a rate of '90.00'

    Then I click "Continue" in the claim form
    And I add a calculated miscellaneous fee 'Noting brief fee' with dates attended '2018-04-01'
    Then the last 'miscellaneous' fee rate should be populated with '108.00'

    And I eject the VCR cassette

    Then I click "Continue" in the claim form

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for scheme 10

    Then I click "Continue" in the claim form

    And I upload the document 'indictment.pdf'
    And I should see 10 evidence check boxes
    And I check the evidence boxes for 'A copy of the indictment'
    And I add some additional information

    Then I click Submit to LAA

    And I should be on the check your claim page
    And I should see 'Caernarfon'
    And I should see 'A20181234'
    And I should see 'Appeal against conviction'

    And I should not see 'Standard Offences'
    And I should see 'Junior'

    And I should see 'Appeals to the crown court against conviction'
    And I should see 'Number of cases uplift'
    And I should see 'Noting brief fee'
    And I should see 'Parking'

    And I should see 'indictment.pdf'
    And I should see 'A copy of the indictment'
    And I should see 'Bish bosh bash'

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the page showing basic claim information

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20181234' should be listed with a status of 'Submitted' and a claimed amount of '£639.07'
