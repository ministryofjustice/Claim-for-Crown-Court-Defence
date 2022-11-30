@javascript
Feature: Advocate partially fills out a draft AGFS scheme 13 interim claim for a warrant fee, then later edits and submits it

  Scenario: I create an AGFS interim claim, save it to draft and later complete it

    Given the current date is '2022-12-30'
    And I am a signed in advocate
    And I am on the 'Your claims' page
    And I click 'Start a claim'
    And I select the fee scheme 'Advocate warrant fee'
    Then I should be on the advocate interim new claim page
    And I should see a page title "Enter case details for advocate warrant fees claim"
    And I select the court 'Blackfriars'
    And I enter a case number of 'A20181234'
    And I enter scheme 13 main hearing date

    When I click "Continue" in the claim form and move to the 'Defendant details' form page
    And I save as draft
    Then I should see 'Draft claim saved'

    Given I am later on the Your claims page
    Then Claim 'A20181234' should be listed with a status of 'Draft'

    When I click the claim 'A20181234'
    And I edit the claim's defendants
    Then I should see a page title "Enter defendant details for advocate warrant fees claim"
    And I enter defendant, scheme 13 representation order and MAAT reference

    When I click "Continue" in the claim form
    Then I should see a page title "Enter offence details for advocate warrant fees claim"
    And I search for a post agfs reform offence 'Absconding from lawful custody'

    When I select the first search result
    Then I should see a page title "Enter fees for advocate warrant fees claim"
    And I select an advocate category of 'Junior'
    And I fill in '2022-09-30' as the warrant issued date
    And I enter a Warrant net amount of '100'

    When I click "Continue" in the claim form
    Then I should see a page title "Enter travel expenses for advocate warrant fees claim"
    And I select an expense type "Parking"
    And I select a travel reason "View of crime scene"
    And I add an expense net amount for "34.56"
    And I add an expense date for scheme 13

    When I click "Continue" in the claim form
    Then I should see a page title "Upload supporting evidence for advocate warrant fees claim"
    And I upload 3 documents
    And I check the boxes for the uploaded documents
    And I add some additional information

    When I click Submit to LAA
    Then I should be on the check your claim page
    And I should see a page title "View claim summary for advocate warrant fees claim"

    When I click "Continue"
    Then I should be on the certification page
    And I should see a page title "Certify and submit the advocate warrant fees claim"
    And I check “I attended the main hearing”
    And I click Certify and submit claim
    Then I should be on the claim confirmation page

    When I click View your claims
    Then I should be on the your claims page
    And Claim 'A20181234' should be listed with a status of 'Submitted' and a claimed amount of '£161.47'
