module Claim
  class LitigatorPermissionClaim < BaseClaim
    route_key_name 'litigators_permission_claim'

    SUBMISSION_STAGES = [
      {
        name: :case_details,
        transitions: [
          { to_stage: :defendants }
        ]
      },
      {
        name: :defendants,
        transitions: [
          { to_stage: :miscellaneous_fees }
        ],
        dependencies: %i[case_details]
      },
      {
        name: :miscellaneous_fees,
        transitions: [
          { to_stage: :expenses }
        ],
        dependencies: %i[defendants]
      }
    ].freeze

    def requires_case_type? = false
  end
end
