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

        DEFENDANT_UPLIFT_MAPPINGS = {
          BASAF: 'MISAU', # Standard appearance fee uplift
          MIAPH: 'MIAHU', # Abuse of process hearings (half day uplift)
          MIAPW: 'MIAWU', # Abuse of process hearings (whole day uplift)
          MIADC1: 'MIADC3', # Application to dismiss a charge (half day uplift)
          MIADC2: 'MIADC4', # Application to dismiss a charge (whole day uplift)
          MIDTH: 'MIDHU', # Confiscation hearings (half day uplift)
          MIDTW: 'MIDWU', # Confiscation hearings (whole day uplift)
          MIDSE: 'MIDSU', # Deferred sentence hearings uplift
          MIAEH: 'MIEHU', # Hearings relating to admissibility of evidence (half day uplift)
          MIAEW: 'MIEWU', # Hearings relating to admissibility of evidence (whole day uplift)
          MIHDH: 'MIHHU', # Hearings relating to disclosure (half day uplift)
          MIHDW: 'MIHWU', # Hearings relating to disclosure (whole day uplift)
          MIPPC: 'MIPCU', # Paper plea & case management uplift
          MIPCH: 'MICHU', # Proceeds of crime hearings (half day uplift)
          MIPCW: 'MICHW', # Proceeds of crime hearings (whole day uplift)
          MIPIH1: 'MIPIU3', # Public interest immunity hearings (half day uplift)
          MIPIH2: 'MIPIH4', # Public interest immunity hearings (whole day uplift)
          MISHR: 'MISHU', # Sentence hearings uplift
          MITNP: 'MITNU', # Trial not proceed uplift
          MIUAV1: 'MIUAV3', # Unsuccessful application to vacate a guilty plea (half day uplift)
          MIUAV2: 'MIUAV4', # Unsuccessful application to vacate a guilty plea (whole day uplift)
        }.with_indifferent_access.freeze

        def claim
          object.object.claim
        end

        def fees_for(fee_type_unique_code)
          claim.fees.where(fee_type_id: ::Fee::BaseFeeType.where(unique_code: fee_type_unique_code))
        end

        def fee_code
          object.fee_type.unique_code
        end

        def defendant_uplift_fee_code
          DEFENDANT_UPLIFT_MAPPINGS[fee_code]
        end

        def matching_defendant_uplift_fees
          fees_for(defendant_uplift_fee_code)
        end

        def number_of_defendants
          matching_defendant_uplift_fees.map(&:quantity).inject(:+).to_i + 1
        end
      end
    end
  end
end
