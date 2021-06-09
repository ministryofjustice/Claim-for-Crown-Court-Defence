@javascript
Feature: Advocate creates, saves, edits then submits a claim for a final fee trial case under scheme 12

  @fee_calc_vcr
  Scenario: Successful submission
    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page
    And I should see a page title "Enter case details for advocate final fees claim"

    When I enter a case number of 'A20181234'
    And I select the court 'Blackfriars'
    And I select a case type of 'Trial'
    And I enter scheme 12 trial start and end dates
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I should see a page title "Enter defendant details for advocate final fees claim"

    When I enter defendant, scheme 12 representation order and MAAT reference
    And I add another defendant, scheme 12 representation order and MAAT reference
    And I click "Continue" in the claim form
    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    And I insert the VCR cassette 'features/claims/advocate/scheme_twelve/trial_claim_edit'
    And I select the first search result
    Then I should be in the 'Graduated fees' form page
    And I should see a page title "Enter graduated fees for advocate final fees claim"
    And I should see the advocate categories 'Junior,Leading junior,QC'
    And I should see the scheme 12 applicable basic fees
    And the basic fee net amount should be populated with '0.00'

    When I select an advocate category of 'Junior'
    Then the basic fee net amount should be populated with '1210.00'

    When I select the 'Number of cases uplift' basic fee with quantity of 1 with case numbers
    And I click "Continue" in the claim form
    Then I should be in the 'Miscellaneous fees' form page
    And I should see 'This claim should be eligible for unused materials fees (up to 3 hours)'

    When I add a calculated miscellaneous fee 'Unused materials (upto 3 hours)' with dates attended '2020-09-20'
    And I save and open screenshot
    And I eject the VCR cassette
    And I click "Continue" in the claim form
    And I save and open screenshot
    And I click the link 'Back'

    Then I should be in the 'Miscellaneous fees' form page
    And I should not see 'This claim should be eligible for unused materials fees (up to 3 hours)'
    And I save and open screenshot
