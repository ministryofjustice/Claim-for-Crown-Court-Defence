require 'rails_helper'

RSpec.describe Claim::TransferBrain do
  include TransferBrainHelpers

  describe '.transfer_stage_by_id' do
    it 'returns the name of the transfer_stage with that id' do
      expect(described_class.transfer_stage_by_id(50).description).to eq 'Transfer before retrial'
    end

    it 'raises if invalid id given' do
      expect { described_class.transfer_stage_by_id(55) }.to raise_error ArgumentError, 'No such transfer stage id: 55'
    end
  end

  describe '.transfer_stage_id' do
    it 'returns the id of the transfer stage with the given name' do
      expect(described_class.transfer_stage_id('Transfer before retrial')).to eq 50
    end

    it 'raises if no such transfer stage with the given name' do
      expect { described_class.transfer_stage_id('xxx') }.to raise_error ArgumentError, "No such transfer stage: 'xxx'"
    end
  end

  describe '.transfer_stage_ids' do
    it 'returns transfer stage ids' do
      expect(described_class.transfer_stage_ids).to eq([10, 20, 30, 40, 50, 60, 70])
    end
  end

  describe '.transfer_stage' do
    subject { described_class.transfer_stage(detail) }

    let(:detail) { build(:transfer_detail, transfer_stage_id: stage_id) }

    context 'with an "Up to and including PCMH transfer" transfer detail' do
      let(:stage_id) { 10 }

      it { is_expected.to have_attributes(id: 10, description: 'Up to and including PCMH transfer', requires_case_conclusion: true) }
    end

    context 'with a "Before trial transfer" transfer detail' do
      let(:stage_id) { 20 }

      it { is_expected.to have_attributes(id: 20, description: 'Before trial transfer', requires_case_conclusion: true) }
    end

    context 'with a "During trial transfer" transfer detail' do
      let(:stage_id) { 30 }

      it { is_expected.to have_attributes(id: 30, description: 'During trial transfer', requires_case_conclusion: true) }
    end

    context 'with a "Transfer after trial and before sentence hearing" transfer detail' do
      let(:stage_id) { 40 }

      it { is_expected.to have_attributes(id: 40, description: 'Transfer after trial and before sentence hearing', requires_case_conclusion: false) }
    end

    context 'with a "Transfer before retrial" transfer detail' do
      let(:stage_id) { 50 }

      it { is_expected.to have_attributes(id: 50, description: 'Transfer before retrial', requires_case_conclusion: true) }
    end

    context 'with a "Transfer during retrial" transfer detail' do
      let(:stage_id) { 60 }

      it { is_expected.to have_attributes(id: 60, description: 'Transfer during retrial', requires_case_conclusion: true) }
    end

    context 'with a "Transfer after retrial and before sentence hearing" transfer detail' do
      let(:stage_id) { 70 }

      it { is_expected.to have_attributes(id: 70, description: 'Transfer after retrial and before sentence hearing', requires_case_conclusion: false) }
    end

    context 'with an unknown transfer detail' do
      let(:stage_id) { 5 }

      it { is_expected.to be_nil }
    end

    context 'with a nil transfer detail' do
      let(:stage_id) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '.case_conclusion_by_id' do
    it 'returns the name of the case conclusion with that id' do
      expect(described_class.case_conclusion_by_id(30)).to eq 'Cracked'
    end

    it 'raises if invalid id given' do
      expect { described_class.case_conclusion_by_id(55) }.to raise_error ArgumentError, 'No such case conclusion id: 55'
    end
  end

  describe '.case_conclusion_id' do
    it 'returns the id of the case conclusion with the given name' do
      expect(described_class.case_conclusion_id('Retrial')).to eq 20
    end

    it 'raises if no such case conclusion with the given name' do
      expect { described_class.case_conclusion_id('xxx') }.to raise_error ArgumentError, "No such case conclusion: 'xxx'"
    end
  end

  describe '.case_conclusion' do
    subject { described_class.case_conclusion(detail) }

    let(:detail) { build(:transfer_detail, case_conclusion_id:) }

    context 'with a "Trial" case conclusion' do
      let(:case_conclusion_id) { 10 }

      it { is_expected.to eq 'Trial' }
    end

    context 'with a "Retrial" case conclusion' do
      let(:case_conclusion_id) { 20 }

      it { is_expected.to eq 'Retrial' }
    end

    context 'with a "Cracked" case conclusion' do
      let(:case_conclusion_id) { 30 }

      it { is_expected.to eq 'Cracked' }
    end

    context 'with a "Cracked before retrial" case conclusion' do
      let(:case_conclusion_id) { 40 }

      it { is_expected.to eq 'Cracked before retrial' }
    end

    context 'with a "Guilty" case conclusion' do
      let(:case_conclusion_id) { 50 }

      it { is_expected.to eq 'Guilty plea' }
    end

    context 'with an unknown case conclusion' do
      let(:case_conclusion_id) { 5 }

      it { is_expected.to be_nil }
    end

    context 'with a nil case conclusion' do
      let(:case_conclusion_id) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '.allocation_type' do
    it 'returns a string describing an allocation filtering type' do
      td = transfer_detail('new', true, 10)
      expect(described_class.allocation_type(td)).to eq 'Fixed'
    end
  end

  describe '.bill_scenario' do
    it 'returns a bill scenario for use in CCLF data injection' do
      td = transfer_detail('new', true, 10)
      expect(described_class.bill_scenario(td)).to eq 'ST4TS0T3'
    end
  end

  describe '.ppe_required' do
    it 'returns a boolean string denoting whether PPE quantity is required for the transfer fee' do
      td = transfer_detail('new', true, 10)
      expect(described_class.ppe_required(td)).to eq 'FALSE'
    end
  end

  describe '.days_claimable' do
    it 'returns a boolean string denoting whether total days claimed (actual_trial_length) quantity effects calculated price' do
      td = transfer_detail('new', true, 10)
      expect(described_class.days_claimable(td)).to eq 'FALSE'
    end
  end

  describe '.transfer_detail_summary' do
    it 'returns a string describing the transfer details' do
      td = transfer_detail('new', true, 10)
      expect(described_class.transfer_detail_summary(td)).to eq 'elected case - up to and including PCMH transfer (new)'
    end
  end

  # only new litigators on unelected case transfers are required to specify case conclusion
  #  i.e. new, false, [10,20,30,50,60]
  describe '.case_conclusion_required?' do
    [10, 20, 30, 50, 60].each do |ts|
      it "is visible for new, unelected cases that were transfered at stage #{ts}" do
        td = transfer_detail('new', false, ts)
        expect(described_class.case_conclusion_required?(td)).to be true
      end
    end

    it 'returns false for nil values' do
      expect(described_class.case_conclusion_required?(transfer_detail(nil, true, 10))).to be false
      expect(described_class.case_conclusion_required?(transfer_detail('new', nil, 10))).to be false
      expect(described_class.case_conclusion_required?(transfer_detail('new', true, nil))).to be false
    end
  end

  def transfer_detail(litigator_type, elected_case, transfer_stage_id, case_conclusion_id = 10)
    build(:transfer_detail, litigator_type:, elected_case:, transfer_stage_id:, case_conclusion_id:)
  end
end
