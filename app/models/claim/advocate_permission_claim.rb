module Claim
  class AdvocatePermissionClaim < BaseClaim
    route_key_name 'advocates_permission_claim'

    include ProviderDelegation

    delegate :agfs?, to: :class

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
    def fee_scheme_factory = FeeSchemeFactory::AGFS
    def permission? = true
  end
end
