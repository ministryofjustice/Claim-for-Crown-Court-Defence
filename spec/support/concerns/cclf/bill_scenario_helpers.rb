module CCLF
  module BillScenarioHelpers
    extend ActiveSupport::Concern

    GRADUATED_FEE_BILL_SCENARIOS = {
      GRDIS: 'ST1TS0T1', # Discontinuance
      GRGLT: 'ST1TS0T2', # Guilty plea
      GRTRL: 'ST1TS0T4', # Trial
      GRRTR: 'ST1TS0TA', # Retrial
      GRRAK: 'ST1TS0T3', # Cracked trial
      GRCBR: 'ST1TS0T9' # Cracked before retrial
    }.freeze

    FIXED_FEE_BILL_SCENARIOS = {
      FXACV: 'ST1TS0T5', # Appeal against conviction
      FXASE: 'ST1TS0T6', # Appeal against sentence
      FXCBR: 'ST3TS3TB', # Breach of Crown Court order
      FXCSE: 'ST1TS0T7', # Committal for Sentence
      FXCON: 'ST1TS0T8', # Contempt
      FXENP: 'ST4TS0T1', # Elected cases not proceeded
      FXH2S: 'ST1TS0TC' # Hearing subsequent to sentence
    }.freeze

    INTERIM_FEE_BILL_SCENARIOS = {
      INPCM: 'ST1TS0T0', # Effective PCMH
      INRNS: 'ST1TS2T0', # Retrial New solicitor
      INRST: 'ST1TS3T0', # Retrial start
      INTDT: 'ST1TS1T0' # Trial start
    }.freeze

    # transfer fee bill scenarios are based on transfer detail combinations,
    # not case type or fee type.
    TRANSFER_FEE_BILL_SCENARIOS = {
      TRANS: ''
    }.freeze

    class_methods do
      def graduated_fee_bill_scenarios
        GRADUATED_FEE_BILL_SCENARIOS
      end

      def fixed_fee_bill_scenarios
        FIXED_FEE_BILL_SCENARIOS
      end

      def final_claim_bill_scenarios
        GRADUATED_FEE_BILL_SCENARIOS.merge(FIXED_FEE_BILL_SCENARIOS)
      end

      def interim_fee_bill_scenarios
        INTERIM_FEE_BILL_SCENARIOS
      end

      def transfer_fee_bill_scenarios
        TRANSFER_FEE_BILL_SCENARIOS
      end
    end
  end
end
