module API
  module Entities
    module CCLF
      class InterimClaim < BaseClaim
        expose :retrial_estimated_length, :estimated_trial_length, format_with: :string

        def bills
          data = []
          data.push AdaptedInterimFee.represent(object.interim_fee)
          data.push AdaptedDisbursement.represent(object.disbursements)
          data.as_json.flat_select { |bill| bill[:bill_type].present? }
        end
      end
    end
  end
end
