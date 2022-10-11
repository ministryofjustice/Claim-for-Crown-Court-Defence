@javascript
Feature: Advocate chooses fee scheme 13 offences and clears them

  Background:
    Given the current date is '2022-10-30'
    And I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    Given I enter a case number of 'A20181234'
    And I select a case type of 'Trial'
    And I select the court 'Blackfriars'
    And I enter scheme 13 trial start and end dates
    Then I click "Continue" in the claim form and move to the 'Defendant details' form page

    Given I enter defendant, scheme 13 representation order and MAAT reference
    And I click "Continue" in the claim form
    Then I should be in the 'Offence details' form page

  Scenario: Choosing scheme 13 offences
    When I search for a post agfs reform offence 'Harbouring escaped prisoner'
    Then I should see 'Band: 8.1'
    When I search for a post agfs reform offence 'Burglary'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 11.2'
    When I search for a post agfs reform offence 'Possession of offensive weapon'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 3.4'
    When I search for a post agfs reform offence 'religiously aggravated common assault'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 3.5'
    When I search for a post agfs reform offence 'Solicitation'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 5.3'
    When I search for a post agfs reform offence 'identity documents with improper intent'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 8.1'
    When I search for a post agfs reform offence 'unauthorised air traffic controllers'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 16.3'

  Scenario: Offence presence and clearing
    Given I click "Continue" in the claim form
    Then I should see govuk error summary with 'Choose an offence'

    Given I search for the scheme 10 offence 'Absconding from lawful custody'
    When I select the first search result
    Then I should be in the 'Graduated fees' form page

    When I click the link 'Back'
    Then I should be in the 'Offence details' form page
    And I should see the selected offence 'Absconding from lawful custody'

    When I click the link 'Clear selection'
    Then I should see no selected offence
