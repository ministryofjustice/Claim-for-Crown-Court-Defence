@javascript
Feature: Signpost for unused materials fees for scheme 12

  Scenario: Unused materials notice displayed for scheme 12 final fee
    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    And I enter a case number of 'A20181234'
    And I select a case type of 'Trial'
    And I select the court 'Blackfriars'
    And I enter scheme 12 trial start and end dates
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I enter defendant, scheme 12 representation order and MAAT reference
    Then I click "Continue" in the claim form
    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    Given I insert the VCR cassette 'features/claims/advocate/scheme_twelve/hardship_fee_calculations'
    When I select the first search result
    And I should be in the 'Graduated fees' form page
    And I select an advocate category of 'Junior'
    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
    Then I should see 'This claim should be eligible for unused materials fees (up to 3 hours)'

  Scenario: Unused materials notice not displayed for scheme 11 final fee
    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    And I enter a case number of 'A20181234'
    And I select a case type of 'Trial'
    And I select the court 'Blackfriars'
    And I enter scheme 11 trial start and end dates
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I enter defendant, scheme 11 representation order and MAAT reference
    Then I click "Continue" in the claim form
    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    Given I insert the VCR cassette 'features/claims/advocate/scheme_eleven/fixed_fee_calculations'
    When I select the first search result
    And I should be in the 'Graduated fees' form page
    And I select an advocate category of 'Junior'
    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
    Then I should not see 'This claim should be eligible for unused materials fees (up to 3 hours)'

  Scenario: Unused materials notice not displayed for scheme 12 warrant fee
    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate hardship fee'
    When I enter a providers reference of 'AGFS hardship claim test'
    And I select the court 'Caernarfon'
    And I enter a case number of 'A20201234'
    When I select a case stage of 'Trial started but not concluded'
    And I enter scheme 12 trial start date
    And I enter an estimated trial length of 10
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I enter defendant, scheme 12 representation order and MAAT reference
    Then I click "Continue" in the claim form
    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    Given I insert the VCR cassette 'features/claims/advocate/scheme_twelve/hardship_fee_calculations'
    When I select the first search result
    And I should be in the 'Hardship fees' form page
    And I select an advocate category of 'Junior'
    Then I click "Continue" in the claim form
    And I should be in the 'Miscellaneous fees' form page
    Then I should not see 'This claim should be eligible for unused materials fees (up to 3 hours)'
