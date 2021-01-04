require 'rails_helper'

RSpec.describe CCR::Fee::FixedFeeAdapter, type: :adapter do
  subject { described_class.new.call(claim) }
  let(:claim) { instance_double('claim') }
  let(:case_type) { instance_double('case_type', fee_type_code: 'FXACV') }

  before do
    allow(claim).to receive(:case_type).and_return case_type
  end

  it_behaves_like 'a mapping fee adapter'

  describe '#bill_type' do
    subject { described_class.new.call(claim).bill_type }

    it 'returns CCR Advocate Fee bill type' do
      is_expected.to eql 'AGFS_FEE'
    end
  end

  describe '#bill_subtype' do
    subject { described_class.new.call(claim).bill_subtype }

    FIXED_FEE_SUBTYPES = {
      FXACV: 'AGFS_APPEAL_CON', # Appeal against conviction
      FXASE: 'AGFS_APPEAL_SEN', # Appeal against sentence
      FXCBR: 'AGFS_ORDER_BRCH', # Breach of Crown Court order
      FXCSE: 'AGFS_COMMITTAL', # Committal for Sentence
      FXENP: 'AGFS_FEE', # Elected cases not proceeded
      FXH2S: nil # Hearing subsequent to sentence??? LGFS only
    }.freeze

    context 'mappings' do
      FIXED_FEE_SUBTYPES.each do |code, bill_subtype|
        context "maps #{code} to #{bill_subtype || 'nil'}" do
          before do
            allow(case_type).to receive(:fee_type_code).and_return code
          end

          it "returns #{bill_subtype || 'nil'}" do
            is_expected.to eql bill_subtype
          end
        end
      end
    end
  end

  describe '#claimed?' do
    subject { described_class.new.call(claim).claimed? }

    context 'when claim is of a fixed fee variety' do
      it 'returns true' do
        is_expected.to eql true
      end
    end

    context 'when claim is not of a fixed fee variety' do
      let(:case_type) { instance_double('case_type', fee_type_code: 'GRTRL') }

      it 'returns false' do
        is_expected.to eql false
      end
    end
  end
end
