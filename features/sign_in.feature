Feature: Sign in
  Scenario: Sign in as an advocate
    Given an "advocate" user account exists
     When I visit the user sign in page
      And I enter my email, password and click sign in
     Then I should be redirected to the advocates landing url

  Scenario: Sign in as an advocate admin
    Given an "advocate admin" user account exists
    When that advocate admin signs in
     Then I should be redirected to the advocates root url

  Scenario: Sign in as a case worker
    Given a "case worker" user account exists
     When I visit the user sign in page
      And I enter my email, password and click sign in
     Then I should be redirected to the "case workers" root url

  Scenario: Sign in as a case worker admin
    Given a "case worker admin" user account exists
     When I visit the user sign in page
      And I enter my email, password and click sign in
     Then I should be redirected to the "case workers admin" root url
