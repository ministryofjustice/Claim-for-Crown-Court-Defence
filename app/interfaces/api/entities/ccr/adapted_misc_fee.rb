module API
  module Entities
    module CCR
      class AdaptedMiscFee < API::Entities::CCR::AdaptedBaseFee
        with_options(format_with: :string) do
          expose :quantity
          expose :rate
          expose :amount
          expose :number_of_defendants
        end

        # TODO: dates attended not available to add to BACAV fee in CCCD interface at the
        # moment but in CCR it is the only misc fee that requires an occured_at date
        # BACAV --> a CCR AGFS_MISC_FEES, AGFS_CONFERENCE
        expose :dates_attended, using: API::Entities::CCR::DateAttended

        private

        # TODO: replace with sum of quantities from misc fee defendant uplifts
        def number_of_defendants
          1
        end
      end
    end
  end
end
