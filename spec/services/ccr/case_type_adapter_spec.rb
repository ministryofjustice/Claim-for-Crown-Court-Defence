require 'rails_helper'

RSpec.describe CCR::CaseTypeAdapter, type: :adapter do
  subject { described_class.new(case_type).bill_scenario }
  let(:case_type) { instance_double('case_type') }

  describe '#bill_scenario' do
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
      GRRTR: 'AS000011', # Retrial
      GRTRL: 'AS000004' # Trial
    }.freeze

    context 'mappings' do
      SCENARIO_MAPPINGS.each do |code, scenario|
        context "maps #{code} to #{scenario}" do
          before do
            allow(case_type).to receive(:fee_type_code).and_return code
          end

          it "returns #{scenario}" do
            is_expected.to eql scenario
          end
        end
      end
    end
  end
end
