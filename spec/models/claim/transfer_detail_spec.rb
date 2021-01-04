# == Schema Information
#
# Table name: transfer_details
#
#  id                 :integer          not null, primary key
#  claim_id           :integer
#  litigator_type     :string
#  elected_case       :boolean
#  transfer_stage_id  :integer
#  transfer_date      :date
#  case_conclusion_id :integer
#

require 'rails_helper'

RSpec.shared_examples 'transfer brain delegator' do |method_name, expected|
  subject(:call) { detail.send(method_name) }

  it 'delegates to transfer brain' do
    expect(Claim::TransferBrain).to receive(method_name).with(described_class)
    call
  end

  if expected.present?
    context 'for a specific transfer detail' do
      it "returns #{method_name}" do
        is_expected.to eq expected
      end
    end
  end
end

RSpec.describe Claim::TransferDetail do
  subject(:detail) { build(:transfer_detail) }

  describe '#unpopulated?' do
    it 'returns true for an empty object' do
      detail = described_class.new
      expect(detail).to be_unpopulated
    end

    it 'returns false if any fields are populated' do
      detail = described_class.new(elected_case: false)
      expect(detail).not_to be_unpopulated
    end
  end

  describe '#errors?' do
    before(:each) { detail.claim = build(:transfer_claim) }

    it 'returns false if there are no errors relating to transfer_detail fields' do
      expect(detail.errors?).to be false
    end

    it 'returns true if any of the transfer detail fields are marked as in error on the claim' do
      detail.claim.errors[:litigator_type] << 'error'
      expect(detail.errors?).to be true
    end

    it 'returns false if claim is nil' do
      detail.claim = nil
      expect(detail.errors?).to be false
    end
  end

  describe '#allocation_type' do
    it_behaves_like 'transfer brain delegator', :allocation_type, 'Fixed' do
      let(:detail) { build(:transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: nil) }
    end
  end

  describe '#bill_scenario' do
    it_behaves_like 'transfer brain delegator', :bill_scenario, 'ST4TS0T3' do
      let(:detail) { build(:transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: nil) }
    end
  end

  describe '#ppe_required' do
    it_behaves_like 'transfer brain delegator', :ppe_required, 'TRUE' do
      let(:detail) { build(:transfer_detail, :with_ppe_required) }
    end

    it_behaves_like 'transfer brain delegator', :ppe_required, 'FALSE' do
      let(:detail) { build(:transfer_detail, :with_ppe_not_required) }
    end
  end

  describe '#ppe_required?' do
    context 'when transfer details require PPE' do
      subject(:detail) { build(:transfer_detail, :with_ppe_required) }
      it { is_expected.to be_ppe_required }
    end

    context 'when transfer details do not require PPE' do
      subject(:detail) { build(:transfer_detail, :with_ppe_not_required) }
      it { is_expected.to_not be_ppe_required }
    end

    context 'when transfer details combination are invalid' do
      subject(:detail) { build(:transfer_detail, :with_invalid_combo) }
      it { is_expected.to_not be_ppe_required }
    end
  end

  describe '#days_claimable' do
    it_behaves_like 'transfer brain delegator', :days_claimable, 'TRUE' do
      let(:detail) { build(:transfer_detail, :with_days_claimable) }
    end

    it_behaves_like 'transfer brain delegator', :days_claimable, 'FALSE' do
      let(:detail) { build(:transfer_detail, :with_days_not_required) }
    end
  end

  describe '#days_claimable?' do
    context 'when transfer details require days' do
      subject(:detail) { build(:transfer_detail, :with_days_claimable) }
      it { is_expected.to be_days_claimable }
    end

    context 'when transfer details do not require days' do
      subject(:detail) { build(:transfer_detail, :with_days_not_required) }
      it { is_expected.to_not be_days_claimable }
    end

    context 'when transfer details combination are invalid' do
      subject(:detail) { build(:transfer_detail, :with_invalid_combo) }
      it { is_expected.to_not be_days_claimable }
    end
  end

  describe '#transfer_stages' do
    it_behaves_like 'transfer brain delegator', :transfer_stage do
      let(:detail) { build(:transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: nil) }
    end

    context 'for a specific transfer detail' do
      subject { detail.transfer_stage }
      let(:detail) { build(:transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: nil) }

      it 'returns a transfer stage struct' do
        is_expected.to be_a Struct::TransferStage
      end

      it 'returns expected transfer stage struct values' do
        is_expected.to eql Struct::TransferStage.new(10, 'Up to and including PCMH transfer', true)
      end
    end
  end
end
