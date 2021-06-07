@javascript
Feature: Advocate creates, saves, edits then submits a claim for a final fee trial case under scheme 12

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
    And I enter scheme 12 trial start and end dates

    And I should see a page title "Enter case details for advocate final fees claim"
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20181234' should be listed with a status of 'Draft'

    When I click the claim 'A20181234'
    And I edit the claim's defendants

    And I enter defendant, scheme 12 representation order and MAAT reference
    And I add another defendant, scheme 12 representation order and MAAT reference

    And I should see a page title "Enter defendant details for advocate final fees claim"
    Then I click "Continue" in the claim form

    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    Given I insert the VCR cassette 'features/claims/advocate/scheme_twelve/trial_claim_edit'

    When I select the first search result
    Then I should be in the 'Graduated fees' form page

    And I should see the advocate categories 'Junior,Leading junior,QC'
    And I should see the scheme 12 applicable basic fees

    And the basic fee net amount should be populated with '0.00'

    And I select an advocate category of 'Junior'
    And the basic fee net amount should be populated with '1210.00'
    And I select the 'Number of cases uplift' basic fee with quantity of 1 with case numbers

    And I should see a page title "Enter graduated fees for advocate final fees claim"
    Then I click "Continue" in the claim form

    And I add a calculated miscellaneous fee 'Special preparation fee' with dates attended '2018-04-01'
    And I add a calculated miscellaneous fee 'Noting brief fee' with dates attended '2018-04-01'
    And I check the section heading to be "2"

    And I eject the VCR cassette

    And I should see 'This claim should be eligible for unused materials fees (up to 3 hours)'
