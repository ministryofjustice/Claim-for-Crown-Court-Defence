module API
  module Entities
    module CCR
      class AdaptedMiscFee < API::Entities::CCR::AdaptedBaseFee
        # May be needed, although currently not made available, for BACAV --> a CCR AGFS_MISC_FEES
        expose :dates_attended, using: API::Entities::CCR::DateAttended
      end
    end
  end
end
