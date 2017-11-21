require 'rails_helper'
require 'spec_helper'
require_relative 'shared_examples_for_fee_adapters'

module CCR
  module Fee
    describe FixedFeeAdapter do
      subject { described_class.new.call(claim) }
      let(:claim) { instance_double('claim') }
      let(:case_type) { instance_double('case_type', fee_type_code: 'FXACV') }

      before do
        allow(claim).to receive(:case_type).and_return case_type
      end

      it_behaves_like 'a fee adapter'

      describe '#bill_type' do
        subject { described_class.new.call(claim).bill_type }

        it 'returns CCR Advocate Fee bill type' do
          is_expected.to eql 'AGFS_FEE'
        end
      end

      describe '#bill_subtype' do
        subject { described_class.new.call(claim).bill_subtype }

        SUBTYPE_MAPPINGS = {
          FXACV: 'AGFS_APPEAL_CON', # Appeal against conviction
          FXASE: 'AGFS_APPEAL_SEN', # Appeal against sentence
          FXCBR: 'AGFS_ORDER_BRCH', # Breach of Crown Court order
          FXCSE: 'AGFS_COMMITTAL', # Committal for Sentence
          FXCON: nil, # Contempt
          FXENP: nil, # Elected cases not proceeded
          FXH2S: nil, # Hearing subsequent to sentence??? LGFS only
        }.freeze

        context 'mappings' do
          SUBTYPE_MAPPINGS.each do |code, bill_subtype|
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

        let(:fixed_fee_type) { instance_double('fixed_fee_type', unique_code: 'FXASE') }
        let(:fixed_fee) do
          instance_double(
            'fixed_fee',
            fee_type: fixed_fee_type,
            quantity: 0,
            rate: 0,
            amount: 0,
            )
        end
        let(:fixed_fees) { [fixed_fee] }

        before do
          allow(claim).to receive(:fixed_fees).and_return fixed_fees
        end

        it 'returns true when the fixed fee has a positive value' do
          allow(fixed_fee).to receive_messages(quantity: 1)
          is_expected.to be true
        end

        it 'returns false when the basic fee has 0 value'do
          allow(fixed_fee).to receive_messages(quantity: 0)
          is_expected.to be false
        end
      end
    end
  end
end
