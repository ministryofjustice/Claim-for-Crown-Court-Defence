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

  describe '.details_combo_valid?' do
    it 'returns false for invalid combos' do
      [30, 40, 60, 70].each do |transfer_stage_id|
        detail = transfer_detail('new', true, transfer_stage_id)
        expect(described_class.details_combo_valid?(detail)).to be false
      end
    end

    it 'returns true for visible combos' do
      [transfer_detail('new', false, 20, 30), transfer_detail('new', false, 30, 20), transfer_detail('new', false, 50, 40)].each do |detail|
        expect(described_class.details_combo_valid?(detail)).to be true
      end
    end

    it 'returns true for hidden combos' do
      [transfer_detail('original', false, 70), transfer_detail('original', true, 50), transfer_detail('original', false, 10)].each do |detail|
        expect(described_class.details_combo_valid?(detail)).to be true
      end
    end
  end

  describe '.data_attributes' do
    subject { described_class.data_attributes }

    it 'returns a JSON representation of the data items collection hash' do
      is_expected.to be_json_eql(data_item_collection_hash.to_json)
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
    it 'returns a boolean string denoting whether total days claimed (actual_trial_length) quantity effects calculated price ' do
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
    [10,20,30,50,60].each do |ts|
      it "should be visible for new, unelected cases that were transfered at stage #{ts}" do
        td = td = transfer_detail('new', false, ts)
        expect(described_class.case_conclusion_required?(td)).to eq true
      end
    end

    it 'returns false for nil values' do
      expect(described_class.case_conclusion_required?(td = transfer_detail(nil, true, 10))).to eq false
      expect(described_class.case_conclusion_required?(td = transfer_detail('new', nil, 10))).to eq false
      expect(described_class.case_conclusion_required?(td = transfer_detail('new', true, nil))).to eq false
    end
  end

  def transfer_detail(litigator_type, elected_case, transfer_stage_id, case_conclusion_id = 10)
    build :transfer_detail, litigator_type: litigator_type, elected_case: elected_case, transfer_stage_id: transfer_stage_id, case_conclusion_id: case_conclusion_id
  end
end
