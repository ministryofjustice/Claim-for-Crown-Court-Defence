FactoryGirl.define do
  factory :transfer_claim, class: Claim::TransferClaim do

    litigator_base_setup
    claim_state_common_traits

    after(:build) do |rec|
      if rec.transfer_detail.nil?
        rec.transfer_detail = build :transfer_detail, claim: rec
      end
    end
  end
end

