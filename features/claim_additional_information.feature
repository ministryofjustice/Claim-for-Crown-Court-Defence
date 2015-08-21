Feature: Claim additional information
  Background:
    As an advocate or case worker I want to be able to see any notes/comments added as "additional information."

    Given There are fee schemes in place

  Scenario: Claim additional information visible to advocates when present
    Given I am a signed in advocate
      And I have a claim
      And the claim has additional information
     When I visit the claim's detail page
     Then I should see the additional information

  Scenario: Claim additional information not visible to advocates when not present
    Given I am a signed in advocate
      And I have a claim
     When I visit the claim's detail page
     Then I should not see the additional information

  Scenario: Claim additional information visible to caseworkers when present
    Given I am a signed in case worker
      And a claim has been assiged to me
      And the claim has additional information
     When I visit the claim's case worker detail page
     Then I should see the additional information

  Scenario: Claim additional information not visible to caseworkers when not present
    Given I am a signed in case worker
      And a claim has been assiged to me
     When I visit the claim's case worker detail page
     Then I should not see the additional information
