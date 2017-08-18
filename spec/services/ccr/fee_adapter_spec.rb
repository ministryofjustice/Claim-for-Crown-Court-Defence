require 'rails_helper'

module CCR
  describe FeeAdapter do
    subject { described_class.new(claim) }
    let(:claim) { create(:authorised_claim) }

    describe '#bill_type' do
      subject { described_class.new(claim).bill_type }

      it 'returns CCR Advocate Fee bill type' do
        is_expected.to eql 'AGFS_FEE'
      end
    end

    describe '#bill_subtype' do
      subject { described_class.new(claim).bill_subtype }

      MAPPINGS = {
        FXACV: 'AGFS_APPEAL_CON', # Appeal against conviction
        FXASE: 'AGFS_APPEAL_SEN', # Appeal against sentence
        FXCBR: 'AGFS_ORDER_BRCH', # Breach of Crown Court order
        FXCSE: 'AGFS_COMMITAL', # Committal for Sentence
        FXCON: 'NOT_ALLOWED', # Contempt
        GRRAK: 'AGFS_FEE', # Cracked Trial
        GRCBR: 'AGFS_FEE', # Cracked before retrial
        GRDIS: 'NOT_ALLOWED', # Discontinuance
        FXENP: 'NOT_ALLOWED', # Elected cases not proceeded
        GRGLT: 'AGFS_FEE', # Guilty plea
        FXH2S: 'NOT_APPLICABLE', # Hearing subsequent to sentence??? LGFS only
        GRRTR: 'AGFS_FEE', # Retrial
        GRTRL: 'AGFS_FEE', # Trial
      }.freeze

      context 'mappings' do
        MAPPINGS.each do |code, bill_subtype|
          context "maps #{code} to #{bill_subtype}" do
            before do
              allow_any_instance_of(CaseType).to receive(:fee_type_code).and_return code
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
