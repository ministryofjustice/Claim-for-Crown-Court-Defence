@javascript
Feature: Advocate submits a claim for a Fixed fee (Appeal against sentence)

  @fee_calc_vcr
  Scenario: I create a contempt claim, then submit it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I select the court 'Blackfriars'
    And I select a case type of 'Appeal against sentence'
    And I enter a case number of 'A20161234'

    Then I click "Continue" in the claim form

    And I enter defendant, representation order and MAAT reference
    And I add another defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    Given I insert the VCR cassette 'features/claims/advocate/scheme_nine/fixed_fee_calculations'

    And I should see the advocate categories 'Junior alone,Led junior,Leading junior,QC'
    And I select an advocate category of 'Junior alone'
    And I choose a fixed fee thing "Something something"


    And the last fixed fee should have fee type options 'Appeals to the crown court against sentence,Number of cases uplift,Number of defendants uplift,Standard appearance fee,"Adjourned appeals, committals and breaches"'

    # And I add a fixed fee 'Adjourned appeals, committals and breaches'
    # Then the last fixed fee case numbers section should not be visible
    # Then the last 'fixed' fee rate should be populated with '108.00'

    # And I add a fixed fee 'Number of cases uplift' with case numbers
    # Then the last fixed fee case numbers section should be visible
    # Then the last 'fixed' fee rate should be populated with '21.60'

    # Then I click "Continue" in the claim form

    # And I add a calculated miscellaneous fee 'Special preparation fee' with dates attended
    # Then the last 'miscellaneous' fee rate should be populated with '39.00'

    # And I eject the VCR cassette

    # Then I click "Continue" in the claim form

    # And I select an expense type "Parking"
    # And I select a travel reason "View of crime scene"
    # And I add an expense net amount for "34.56"
    # And I add an expense date for scheme 9

    # Then I click "Continue" in the claim form

    # And I upload 3 documents
    # And I check the boxes for the uploaded documents
    # And I add some additional information

    # Then I click Submit to LAA
    # And I should be on the check your claim page

    # When I click "Continue"
    # Then I should be on the certification page

    # When I check “I attended the main hearing”
    # And I click Certify and submit claim
    # Then I should be on the page showing basic claim information

    # When I click View your claims
    # Then I should be on the your claims page
    # And Claim 'A20161234' should be listed with a status of 'Submitted' and a claimed amount of '£243.79'
