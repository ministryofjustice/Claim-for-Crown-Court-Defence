RSpec.shared_context 'claim-types helpers' do
  let(:agfs_claim_types) { %w[agfs agfs_interim agfs_supplementary agfs_hardship agfs_permission] }
  let(:lgfs_claim_types) { %w[lgfs_final lgfs_interim lgfs_transfer lgfs_hardship lgfs_permission] }
  let(:all_claim_types) { agfs_claim_types | lgfs_claim_types }
end

RSpec.shared_context 'claim-types object helpers' do
  let(:agfs_claim_object_types) { %w[Claim::AdvocateClaim Claim::AdvocateInterimClaim Claim::AdvocateSupplementaryClaim Claim::AdvocateHardshipClaim Claim::AdvocatePermissionClaim] }
  let(:lgfs_claim_object_types) { %w[Claim::LitigatorClaim Claim::InterimClaim Claim::TransferClaim Claim::LitigatorHardshipClaim Claim::LitigatorPermissionClaim] }
  let(:all_claim_object_types) { agfs_claim_object_types | lgfs_claim_object_types }

  # Usable outside examples
  class << self
    def agfs_claim_type_objects
      [Claim::AdvocateClaim, Claim::AdvocateInterimClaim, Claim::AdvocateSupplementaryClaim, Claim::AdvocateHardshipClaim]
    end

    def lgfs_claim_type_objects
      [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim]
    end

    def all_claim_type_objects
      agfs_claim_type_objects | lgfs_claim_type_objects
    end
  end
end
