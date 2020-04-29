@javascript
Feature: Litigator completes a hardship claim

  @fee_calc_vcr
  Scenario: I create a hardship claim

    Given I am a signed in litigator
    And My provider has supplier numbers
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Litigator hardship fee'
    Then I should be on the litigator new hardship claim page

    When I choose the supplier number '1A222Z'
    And I enter a providers reference of 'LGFS test hardship fee for covid-19'
    And I select the court 'Blackfriars'
    And I select a case type of 'PTPH not happened or been adjourned'
    And I enter a case number of 'A20201234'

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I should see a page title "Enter defendant details for litigator hardship fees claim"

    And I enter defendant, LGFS representation order and MAAT reference
    And I add another defendant, LGFS representation order and MAAT reference

    And I should see a page title "Enter defendant details for litigator hardship fees claim"
    Then I click "Continue" in the claim form

    And I select the offence category 'Handling stolen goods'
    And I select the advocate offence class 'G: Other offences of dishonesty between £30,001 and £100,000'

    Given I insert the VCR cassette 'features/claims/litigator/hardship_fee_calculations'

    And I should see a page title "Enter offence details for litigator hardship fees claim"
    When I click "Continue" in the claim form

    And I should be in the 'Hardship fee' form page
    When I enter '50' in the PPE total hardship fee field
    Then the hardship fee amount should be populated with '429.12'
    And I eject the VCR cassette

    Then I click "Continue" in the claim form and move to the 'Miscellaneous fees' form page
    Then I click "Continue" in the claim form and move to the 'Supporting evidence' form page

    And I should see a page title "Upload supporting evidence for litigator hardship fees claim"
    And I upload the document 'hardship.pdf'
    And I check the evidence boxes for 'Hardship supporting evidence'
    And I add some additional information

    And I click Submit to LAA
    Then I should be on the check your claim page
    And I should see 'Blackfriars'
    And I should see 'A20201234'
    And I should see 'Trial'

    And I should see 'Handling stolen goods'
    And I should see 'G: Other offences of dishonesty between £30,001 and £100,000'

    And I should see 'Hardship fees'
    And I should see 'PPE total at the time 50'
    And I should see 'Net amount £429.12'


    And I should see 'hardship.pdf'
    And I should see 'Hardship supporting evidence'
    And I should see 'Bish bosh bash'
    And I should see a page title "View claim summary for litigator hardship fees claim"
    When I click "Continue"
    Then I should be on the certification page

    And I should see a page title "Certify and submit the litigator hardship fees claim"
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20201234' should be listed with a status of 'Submitted' and a claimed amount of '£429.12'
