@javascript
Feature: Advocate creates a claim for a final fee trial case under scheme 11

  Scenario: Successful renders scheme 11 offences
    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate final fee'
    Then I should be on the new claim page

    And I enter a case number of 'A20181234'

    And I AUTO select a case type of 'Breach of Crown Court order'

    And I AUTO select the court 'Blackfriars'

    And I enter scheme 11 trial start and end dates

    Then I click "Continue" in the claim form

    And I enter defendant, scheme 11 representation order and MAAT reference
    Then I click "Continue" in the claim form
    And I should be in the 'Offence details' form page

    And I search for a post agfs reform offence 'Harbouring escaped prisoner'
    Then I should see 'Band: 8.1'
    And I search for a post agfs reform offence 'Burglary'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 11.2'
    And I search for a post agfs reform offence 'Possession of offensive weapon'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 3.4'
    And I search for a post agfs reform offence 'religiously aggravated common assault'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 3.5'
    And I search for a post agfs reform offence 'Solicitation'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 5.3'
    And I search for a post agfs reform offence 'identity documents with improper intent'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 8.1'
    And I search for a post agfs reform offence 'unauthorised air traffic controllers'
    Then the offence should have moved from 'Band: 17.1' to 'Band: 16.3'
