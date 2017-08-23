require 'rails_helper'
require 'spec_helper'

module CCR
  describe FeeAdapter do
    let(:claim) { instance_double('claim') }
    let(:case_type) { instance_double('case_type') }

    before do
      allow(claim).to receive(:case_type).and_return case_type
    end

    describe '#bill_type' do
      subject { described_class.new(claim).bill_type }

      before do
        allow(case_type).to receive(:fee_type_code).and_return 'GRTRL'
      end

      it 'returns CCR Advocate Fee bill type' do
        is_expected.to eql 'AGFS_FEE'
      end
    end

    describe '#bill_subtype' do
      subject { described_class.new(claim).bill_subtype }

      SUBTYPE_MAPPINGS = {
        FXACV: 'AGFS_APPEAL_CON', # Appeal against conviction
        FXASE: 'AGFS_APPEAL_SEN', # Appeal against sentence
        FXCBR: 'AGFS_ORDER_BRCH', # Breach of Crown Court order
        FXCSE: 'AGFS_COMMITTAL', # Committal for Sentence
        FXCON: nil, # Contempt
        GRRAK: 'AGFS_FEE', # Cracked Trial
        GRCBR: 'AGFS_FEE', # Cracked before retrial
        GRDIS: nil, # Discontinuance
        FXENP: nil, # Elected cases not proceeded
        GRGLT: 'AGFS_FEE', # Guilty plea
        FXH2S: nil, # Hearing subsequent to sentence??? LGFS only
        GRRTR: 'AGFS_FEE', # Retrial
        GRTRL: 'AGFS_FEE', # Trial
      }.freeze

      context 'mappings' do
        SUBTYPE_MAPPINGS.each do |code, bill_subtype|
          context "maps #{code} to #{bill_subtype}" do
            before do
              allow(case_type).to receive(:fee_type_code).and_return code
            end

            it "returns #{bill_subtype}" do
              is_expected.to eql bill_subtype
            end
          end
        end
      end
    end
  end
end
