module API
  module Entities
    module CCR
      class AdaptedMiscFee < API::Entities::CCR::AdaptedBaseFee
        expose :quantity
        expose :rate
        expose :amount
        # TODO: dates attended not available to add to BACAV fee in CCCD interface at the
        # moment but in CCR it is the only misc fee that requires an occured_at date
        # BACAV --> a CCR AGFS_MISC_FEES, AGFS_CONFERENCE
        expose :dates_attended, using: API::Entities::CCR::DateAttended
      end
    end
  end
end
