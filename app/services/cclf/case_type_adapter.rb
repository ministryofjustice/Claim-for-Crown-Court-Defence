module CCLF
  class CaseTypeAdapter
    attr_reader :case_type

    # TODO: these are for final claim bill scenarios, interim and tranfer claims equivalent
    SCENARIO_MAPPINGS = {
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
    }.freeze

    def initialize(case_type)
      @case_type = case_type
    end

    class << self
      def bill_scenario(case_type)
        adapter = new(case_type)
        adapter.bill_scenario
      end
    end

    def bill_scenario
      SCENARIO_MAPPINGS[case_type.fee_type_code.to_sym]
    end
  end
end
