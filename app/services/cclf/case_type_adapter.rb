module CCLF
  class CaseTypeAdapter
    # TODO: transfer claims only
    #
    # NOTE: on the missing interim fee types:
    # - Interim "Warrant" (INWAR) fees are handled as "final" warrant fees, using the case_type.fee_type_code.
    # - Interim "Disbursement only" (INDIS) fee is merely a flag to indicate only disbursements are
    #   required, so is not mapped.
    #
    BILL_SCENARIOS = {
      FXACV: 'ST1TS0T5', # Appeal against conviction
      FXASE: 'ST1TS0T6', # Appeal against sentence
      FXCBR: 'ST3TS3TB', # Breach of Crown Court order
      FXCSE: 'ST1TS0T7', # Committal for Sentence
      FXCON: 'ST1TS0T8', # Contempt
      FXENP: 'ST4TS0T1', # Elected cases not proceeded
      FXH2S: 'ST1TS0TC', # Hearing subsequent to sentence
      GRDIS: 'ST1TS0T1', # Discontinuance
      GRGLT: 'ST1TS0T2', # Guilty plea
      GRTRL: 'ST1TS0T4', # Trial
      GRRTR: 'ST1TS0TA', # Retrial
      GRRAK: 'ST1TS0T3', # Cracked trial
      GRCBR: 'ST1TS0T9', # Cracked before retrial
      INPCM: 'ST1TS0T0', # Interim Claim - Effective PCMH - Trial only
      INTDT: 'ST1TS1T0', # Interim Claim - Trial start - Trial only
      INRNS: 'ST1TS2T0', # Interim Claim - Retrial New solicitor - Retrial only
      INRST: 'ST1TS3T0', # Interim Claim - Retrial start - Retrial only
    }.freeze

    def initialize(claim)
      @claim = claim
    end

    attr_reader :claim

    def bill_scenario
      return interim_bill_scenario if interim_scenario_applicable?
      return transfer_bill_scenario if transfer_scenario_applicable?
      final_bill_scenario
    end

    private

    def interim_scenario_applicable?
      claim.interim? && interim_bill_scenario
    end

    def interim_bill_scenario
      BILL_SCENARIOS[claim.interim_fee&.fee_type&.unique_code&.to_sym]
    end

    def transfer_scenario_applicable?
      claim.transfer? && transfer_bill_scenario
    end

    def transfer_bill_scenario
      claim.transfer_detail&.bill_scenario
    end

    def final_bill_scenario
      BILL_SCENARIOS[claim.case_type.fee_type_code.to_sym]
    end
  end
end
