Feature: Trial detail visibility by case type
  Background:
    As an advocate I want to see trial detail fields for
    trial case types only

    Given case types are seeded

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Case types for which trial details should or should not be visible on a new claim
    Given I am a signed in advocate
      And I am on the new claim page
     Then I should not see the trial detail fields
     When I select2 "<case_type>" from "claim_case_type_id"
     Then I <condition> see the trial detail fields

  Examples:
    | case_type                   | condition  |
    | Appeal against conviction   | should not |
    | Appeal against sentence     | should not |
    | Breach of Crown Court order | should not |
    | Committal for Sentence      | should not |
    | Contempt                    | should not |
    | Cracked Trial               | should not |
    | Cracked before retrial      | should not |
    | Elected cases not proceeded | should not |
    | Guilty plea                 | should not |
    | Discontinuance              | should not |
    | Retrial                     | should     |
    | Trial                       | should     |

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Case types for which trial details should or should not be visible on an existing claim
    Given I am a signed in advocate
      And I am on the edit page for a draft claim of case type "<case_type>"
     Then I <condition> see the trial detail fields

    Examples:
      | case_type                   | condition  |
      | Appeal against conviction   | should not |
      | Appeal against sentence     | should not |
      | Breach of Crown Court order | should not |
      | Committal for Sentence      | should not |
      | Contempt                    | should not |
      | Cracked Trial               | should not |
      | Cracked before retrial      | should not |
      | Elected cases not proceeded | should not |
      | Guilty plea                 | should not |
      | Discontinuance              | should not |
      | Retrial                     | should     |
      | Trial                       | should     |

@javascript @webmock_allow_localhost_connect
  Scenario Outline: Case types for which retrial details should or should not be visible on a new claim
    Given I am a signed in advocate
      And I am on the new claim page
     Then I should not see the retrial detail fields
     When I select2 "<case_type>" from "claim_case_type_id"
     Then I <condition> see the retrial detail fields

  Examples:
    | case_type                   | condition  |
    | Appeal against conviction   | should not |
    | Appeal against sentence     | should not |
    | Breach of Crown Court order | should not |
    | Committal for Sentence      | should not |
    | Contempt                    | should not |
    | Cracked Trial               | should not |
    | Cracked before retrial      | should not |
    | Elected cases not proceeded | should not |
    | Guilty plea                 | should not |
    | Discontinuance              | should not |
    | Retrial                     | should     |
    | Trial                       | should not |

  @javascript @webmock_allow_localhost_connect
  Scenario Outline: Case types for which retrial details should or should not be visible on an existing claim
    Given I am a signed in advocate
      And I am on the edit page for a draft claim of case type "<case_type>"
     Then I <condition> see the retrial detail fields

    Examples:
      | case_type                   | condition  |
      | Appeal against conviction   | should not |
      | Appeal against sentence     | should not |
      | Breach of Crown Court order | should not |
      | Committal for Sentence      | should not |
      | Contempt                    | should not |
      | Cracked Trial               | should not |
      | Cracked before retrial      | should not |
      | Elected cases not proceeded | should not |
      | Guilty plea                 | should not |
      | Discontinuance              | should not |
      | Retrial                     | should     |
      | Trial                       | should not |
