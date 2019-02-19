@javascript
Feature: Advocate creates, saves, edits then submits a claim for a final fee trial case under scheme 10

  @fee_calc_vcr
  Scenario: Successful submission
    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I enter a case number of 'A20181234'
    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter scheme 10 trial start and end dates

    And I should see a page title "Enter case details for advocate final fees claim"
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20181234' should be listed with a status of 'Draft'

    When I click the claim 'A20181234'
    And I edit the claim's defendants

    And I enter defendant, scheme 10 representation order and MAAT reference
    And I add another defendant, scheme 10 representation order and MAAT reference

    And I should see a page title "Enter defendant details for advocate final fees claim"
    Then I click "Continue" in the claim form

    And I search for the scheme 10 offence 'Absconding from lawful custody'
    Given I insert the VCR cassette 'features/claims/advocate/scheme_ten/trial_claim_edit'

    When I select the first search result
    Then I should be in the 'Graduated fees' form page

    And I should see the advocate categories 'Junior,Leading junior,QC'
    And I should see the scheme 10 applicable basic fees

    And the basic fee net amount should be populated with '0.00'

    And I select an advocate category of 'Junior'
    And the basic fee net amount should be populated with '550.00'
    And I add a number of cases uplift fee with additional case numbers

    And I should see a page title "Enter graduated fees for advocate final fees claim"
    Then I click "Continue" in the claim form

    And I add a calculated miscellaneous fee 'Special preparation fee' with dates attended '2018-04-01'
    And I check the section heading to be "1"
    And I add a calculated miscellaneous fee 'Noting brief fee' with dates attended '2018-04-01'
    And I check the section heading to be "2"

    And I eject the VCR cassette

    And I should see a page title "Enter miscellaneous fees for advocate final fees claim"
    Then I click "Continue" in the claim form

    And I select an expense type "Hotel accommodation"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense location
    And I add an expense date for scheme 10

    And I should see a page title "Enter travel expenses for advocate final fees claim"
    Then I click "Continue" in the claim form

    And I upload the document 'judicial_appointment_order.pdf'
    And I should see 10 evidence check boxes
    And I check the evidence boxes for 'Order in respect of judicial apportionment,A copy of the indictment'
    And I add some additional information

    And I should see a page title "Upload supporting evidence for advocate final fees claim"
    Then I click Submit to LAA

    Then I should be on the check your claim page
    And I should see 'Blackfriars'
    And I should see 'A20181234'
    And I should see 'Trial'

    And I should see 'Standard Offences'
    And I should see '17.1'
    And I should see 'Absconding from lawful custody'
    And I should see 'Junior'

    And I should see 'Basic fee'
    And I should see 'Number of cases uplift'
    And I should see 'Special preparation fee'
    And I should see 'Noting brief fee'
    And I should see 'Hotel accommodation'

    And I should see 'judicial_appointment_order.pdf'
    And I should see 'Order in respect of judicial apportionment'
    And I should see 'Bish bosh bash'

    And I should see a page title "View claim summary for advocate final fees claim"
    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”

    And I should see a page title "Certify and submit the advocate final fees claim"
    And I click Certify and submit claim

    Then I should be on the claim confirmation page
    And I should see a page title "Thank you for submitting your claim"

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20181234' should be listed with a status of 'Submitted' and a claimed amount of '£1,117.87'
