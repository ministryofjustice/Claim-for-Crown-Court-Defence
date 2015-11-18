Feature: Sign in

  Scenario: Sign in as an advocate
    Given an "advocate" user account exists
     When I visit the user sign in page
      And I enter my email, password and click sign in
     Then I should be redirected to the advocates root url
      And I should see the advocates correct working primary navigation
      And I should see the get in touch contact link

  Scenario: Sign in as an advocate admin
    Given an "advocate admin" user account exists
     When that advocate admin signs in
     Then I should be redirected to the advocates root url
      And I should see the admin advocates correct working primary navigation
      And I should see the get in touch contact link

  Scenario: Sign in as a case worker
    Given a "case worker" user account exists
     When I visit the user sign in page
      And I enter my email, password and click sign in
     Then I should be redirected to the "case workers" root url
      And I should see the caseworkers correct working primary navigation
      And I should see the get in touch contact link

  Scenario: Sign in as a case worker admin
    Given a "case worker admin" user account exists
     When I visit the user sign in page
      And I enter my email, password and click sign in
     Then I should be redirected to the "case workers admin" root url
      And I should see the admin caseworkers correct working primary navigation
      And I should see the get in touch contact link

  Scenario: Three failed signed in attempts locks user out for 10 minutes
    Given an "advocate" user account exists
     When I visit the user sign in page
      And I enter my email and the wrong password 3 times
     Then I should no longer be able to sign in
     When the 10 minute lockout duration has expired then I should be able to sign in again

  Scenario: Sign in as a super admin
    Given a "super admin" user account exists
     When I visit the user sign in page
      And I enter my email, password and click sign in
     Then I should be redirected to the "super admins" root url
      And I should see the superadmins correct working primary navigation
