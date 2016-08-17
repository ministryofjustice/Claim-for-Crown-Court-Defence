require 'rails_helper'

RSpec.describe DisbursementPresenter do

  let(:claim) { instance_double(Claim::LitigatorClaim) }
  let(:disbursement_type) { instance_double(DisbursementType, name: 'name') }
  let(:disbursement) { instance_double(Disbursement, disbursement_type: disbursement_type, claim: claim, net_amount: 1.456, vat_amount: 2.343) }

  subject { described_class.new(disbursement, view) }

  describe '#name' do
    it 'returns the disbursement type name' do
      expect(subject.name).to eq('name')
    end

    context 'when disbursement type was not specified' do
      let(:disbursement_type) { nil }

      it 'returns a placeholder text' do
        expect(subject.name).to eq('not provided')
      end
    end
  end

  describe '#net_amount' do
    it 'returns the net_amount rounded and formatted' do
      expect(subject.net_amount).to eq('£1.46')
    end
  end

  describe '#vat_amount' do
    it 'returns the vat_amount rounded and formatted' do
      expect(subject.vat_amount).to eq('£2.34')
    end
  end
end
