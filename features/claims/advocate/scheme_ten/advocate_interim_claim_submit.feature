@javascript
Feature: Advocate partially fills out a draft AGFS interim claim for a trial, then later edits and submits it

  Scenario: I create an AGFS interim claim, save it to draft and later complete it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate warrant fee'
    Then I should be on the advocate interim new claim page

    And I select the court 'Blackfriars'
    And I enter a case number of 'A20181234'

    Then I click "Continue" in the claim form
    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20181234' should be listed with a status of 'Draft'

    When I click the claim 'A20181234'
    And I edit the claim's defendants
    And I enter a scheme 10 defendant, representation order and MAAT reference

    Then I click "Continue" in the claim form

    And I search for the scheme 10 offence 'Absconding from lawful custody'
    Then I select the first search result

    And I select an advocate category of 'Junior'
    And I fill in '2018-04-01' as the warrant issued date
    And I enter a Warrant net amount of '100'

    Then I click "Continue" in the claim form

    And I add an expense 'Parking'

    Then I click "Continue" in the claim form

    And I upload 3 documents
    And I check the boxes for the uploaded documents
    And I add some additional information

    And I click Submit to LAA
    Then I should be on the check your claim page

    When I click "Continue"
    Then I should be on the certification page

    When I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the page showing basic claim information

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20181234' should be listed with a status of 'Submitted' and a claimed amount of '£161.47'
