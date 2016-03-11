@advocate @javascript @webmock_allow_localhost_connect
##
# TODO This feature shouldn't be so reliant on actual case types
#      it should just be testing show/hide js code
#      We should factory create 3 case types
#      1 case type() that displays trials only fields
#      1 case type that displays trial/retrial fields
#      1 case type that shouldn't display either
#      requires_trial_dates and requires_retrial_dates attributes on the case_types table
#      determine whether trial/retrials fields should be displayed . only boolean values

Feature: Trial detail visibility by case type
  Background:
    As an advocate I want to see trial detail fields for
    trial case types only.

    As an advocate I want to see retrial detail fields for
    retrial case types only.

    Given I am a signed in advocate
      And case types are seeded

  Scenario: For a new claims, Trial details should only be visible for specific case types
    Given  I am on the new claim page
      And the following claim case types and conditions:
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
        | Trial                       | should     |
        | Retrial                     | should     |

     When I change the claim case types for trial
     Then the trial details should be conditionally shown


  Scenario: For an existing claim, Trial details should only be visible for specific case types
    Given a claims has a case type that conditionally displays fields as:
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

     When I am on the edit page for a draft claim of trial specific case type
     Then the retrial details should be conditionally shown


  Scenario: For a new claims, Retrial details should only be visible for specific case types
    Given I am on the new claim page
      And the following claim case types and conditions:
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
        | Trial                       | should not |
        | Retrial                     | should     |

      When I change the claim case types for retrial
      Then the retrial details should be conditionally shown


  Scenario: For an existing claims, Retrial details should only be visible for specific case types
    Given a claims has a case type that conditionally displays fields as:
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
        | Trial                       | should not |
        | Retrial                     | should     |

     When I am on the edit page for a draft claim of retrial specific case type
     Then the retrial details should be conditionally shown
