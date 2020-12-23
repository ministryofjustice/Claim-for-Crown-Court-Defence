module API
  module Entities
    module CCLF
      class HardshipClaim < BaseClaim
        def bills
          data = []
          data.push AdaptedHardshipFee.represent(object.hardship_fee)
          data.push AdaptedMiscFee.represent(object.misc_fees)
          data.as_json.flat_select { |bill| bill[:bill_type].present? }
        end
      end
    end
  end
end
