require 'rails_helper'

module CCLF
  describe CaseTypeAdapter do
    let(:case_type) { instance_double('case_type') }

    describe '#bill_scenario' do
      subject { described_class.new(case_type).bill_scenario }

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
end
