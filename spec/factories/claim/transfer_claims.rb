FactoryGirl.define do
  factory :transfer_claim, class: Claim::TransferClaim do

    type 'Claim::TransferClaim'           # remove when transfer claim derives from Claim::BaseClaim or LitigatorClaim

    after(:build) do |rec|
      if rec.transfer_detail.nil?
        rec.transfer_detail = build :transfer_detail, claim: rec
      end
    end
  end
end

