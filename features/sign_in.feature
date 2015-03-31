Feature: Sign in
  Scenario: Sign in as an advocate
    Given an "advocate" user account exists
     When I vist the user sign in page
      And I enter my email, password and click log in
     Then I should be redirected to the "advocates" root url

  Scenario: Sign in as a case worker
    Given a "case worker" user account exists
     When I vist the user sign in page
      And I enter my email, password and click log in
     Then I should be redirected to the "case workers" root url
