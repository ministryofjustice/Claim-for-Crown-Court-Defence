Feature: Claim AGFS LGFS choice
  Background:
    As a admin of a firm that can submit both AGFS and LGFS claims I would like to be given the choice
    of which type of claim to create

    Given I am a signed in admin for an AGFS and LGFS firm

  Scenario: I can create an AGFS claim or an LGFS firm
     When I start a claim
     Then I should be redirected to the claim scheme choice page
