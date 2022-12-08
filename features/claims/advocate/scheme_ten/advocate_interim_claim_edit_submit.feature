@javascript
Feature: Advocate partially fills out a draft AGFS scheme 10 interim claim for a warrant fee, then later edits and submits it

  Scenario: I create an AGFS interim claim, save it to draft and later complete it

    Given I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate warrant fee'
    Then I should be on the advocate interim new claim page

    And I select the court 'Blackfriars'
    And I enter a case number of 'A20181234'
    And I enter scheme 10 main hearing date

    And I should see a page title "Enter case details for advocate warrant fees claim"

    Then I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20181234' should be listed with a status of 'Draft'

    When I click the claim 'A20181234'
    And I edit the claim's defendants
    And I enter defendant, scheme 10 representation order and MAAT reference

    And I should see a page title "Enter defendant details for advocate warrant fees claim"
    Then I click "Continue" in the claim form

    And I search for the scheme 10 offence 'Absconding from lawful custody'
    Then I select the first search result

    And I select an advocate category of 'Junior'
    And I fill in '2018-04-01' as the warrant issued date
    And I enter a Warrant net amount of '100'

    And I should see a page title "Enter fees for advocate warrant fees claim"
    Then I click "Continue" in the claim form

    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for scheme 10

    And I should see a page title "Enter travel expenses for advocate warrant fees claim"
    Then I click "Continue" in the claim form

    And I upload 3 documents
    And I check the boxes for the uploaded documents
    And I add some additional information

    And I should see a page title "Upload supporting evidence for advocate warrant fees claim"
    And I click Submit to LAA
    Then I should be on the check your claim page

    And I should see a page title "View claim summary for advocate warrant fees claim"
    When I click "Continue"

    Then I should be on the certification page
    When I check “I attended the main hearing”

    And I should see a page title "Certify and submit the advocate warrant fees claim"
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20181234' should be listed with a status of 'Submitted' and a claimed amount of '£161.47'
