require 'rails_helper'

RSpec.describe API::Services::ResourceAdapter do
  subject { described_class.new(resource) }

  let(:resource) { {} }
  it { is_expected.to respond_to(:call) }

  describe '#call' do
    subject { described_class.new(resource).call }

    context 'LGFS' do
      context 'graduated fee' do
        let(:resource) { build(:graduated_fee, quantity: nil, rate: nil, amount: 349.47) }

        it 'does not reassign attributes' do
          expect(resource).to_not receive(:assign_attributes)
          subject
        end
      end

      context 'fixed fees' do
        context 'for post-fee-calculation attributes' do
          let(:attributes) { { quantity: 1, rate: 349.47, amount: nil } }
          let(:resource) { build(:fixed_fee, :lgfs, **attributes) }

          it 'does not reassign attributes' do
            expect(resource).to_not receive(:assign_attributes)
            subject
          end

          it 'returns unmodified resource' do
            is_expected.to have_attributes(attributes)
          end
        end

        context 'for pre-fee-calculation attributes' do
          let(:attributes) { { quantity: nil, rate: nil, amount: 349.97 } }
          let(:resource) { build(:fixed_fee, :lgfs, **attributes) }

          it 'reassigns attributes' do
            expect(resource).to receive(:assign_attributes)
            subject
          end

          it 'returns modified quantity, rate and amount' do
            is_expected.to have_attributes(quantity: 1, rate: 349.97, amount: nil)
          end
        end
      end
    end
  end
end
