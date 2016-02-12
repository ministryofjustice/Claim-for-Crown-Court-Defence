Feature: Trial detail visibility by case type
  Background:
    As an advocate I want to see trial detail fields for
    trial case types only

    Given case types are seeded

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Case types for which trial and retrial details should or should not be visible on a new claim
    Given I am a signed in advocate
      And I am on the new claim page
     Then I should not see the trial detail fields
      And I should not see the retrial detail fields
     When I select2 "<case_type>" from "claim_case_type_id"
     Then I <trial_condition> see the trial detail fields
      And I <retrial_condition> see the retrial detail fields

  Examples:
    | case_type                   | trial_condition  | retrial_condition |
    | Appeal against conviction   | should not       | should not        |
    | Appeal against sentence     | should not       | should not        |
    | Breach of Crown Court order | should not       | should not        |
    | Committal for Sentence      | should not       | should not        |
    | Contempt                    | should not       | should not        |
    | Cracked Trial               | should not       | should not        |
    | Cracked before retrial      | should not       | should not        |
    | Elected cases not proceeded | should not       | should not        |
    | Guilty plea                 | should not       | should not        |
    | Discontinuance              | should not       | should not        |
    | Retrial                     | should           | should            |
    | Trial                       | should           | should not        |

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Case types for which trial and retrial details should or should not be visible on an existing claim
    Given I am a signed in advocate
      And I am on the edit page for a draft claim of case type "<case_type>"
     Then I <trial_condition> see the trial detail fields
      And I <retrial_condition> see the retrial detail fields

  Examples:
    | case_type                   | trial_condition  | retrial_condition |
    | Appeal against conviction   | should not       | should not        |
    | Appeal against sentence     | should not       | should not        |
    | Breach of Crown Court order | should not       | should not        |
    | Committal for Sentence      | should not       | should not        |
    | Contempt                    | should not       | should not        |
    | Cracked Trial               | should not       | should not        |
    | Cracked before retrial      | should not       | should not        |
    | Elected cases not proceeded | should not       | should not        |
    | Guilty plea                 | should not       | should not        |
    | Discontinuance              | should not       | should not        |
    | Retrial                     | should           | should            |
    | Trial                       | should           | should not        |
