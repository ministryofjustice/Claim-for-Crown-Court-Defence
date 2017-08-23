module CCR
  class CaseTypeAdapter
    attr_reader :case_type

    SCENARIO_MAPPINGS = {
      FXACV: 'AS000005', # Appeal against conviction
      FXASE: 'AS000006', # Appeal against sentence
      FXCBR: 'AS000009', # Breach of Crown Court order
      FXCSE: 'AS000007', # Committal for Sentence
      FXCON: 'AS000008', # Contempt
      GRRAK: 'AS000003', # Cracked Trial
      GRCBR: 'AS000010', # Cracked before retrial
      GRDIS: 'AS000001', # Discontinuance
      FXENP: 'AS000014', # Elected cases not proceeded
      GRGLT: 'AS000002', # Guilty plea
      FXH2S: nil, # Hearing subsequent to sentence??? LGFS only
      GRRTR: 'AS000011', # Retrial
      GRTRL: 'AS000004', # Trial
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
