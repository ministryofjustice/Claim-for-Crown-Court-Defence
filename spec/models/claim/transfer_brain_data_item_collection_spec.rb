require 'rails_helper'

RSpec.describe Claim::TransferBrainDataItemCollection do
  include TransferBrainHelpers

  subject(:collection) { described_class.instance }

  # specific mapping: where there is a case conclusion id specific mapping (case conclusion is relevant)
  # wildcard mapping: where there is mapping for any case conclusion id, using "*" key (i.e. case conclusion is irrelevant)
  # invalid: where the combination of details is not possible
  let(:with_wildcard_mapping) { build(:transfer_detail, :with_wildcard_mapping) }
  let(:with_specific_mapping) { build(:transfer_detail, :with_specific_mapping) }
  let(:with_invalid_combo) { build(:transfer_detail, :with_invalid_combo) }

  describe '.new' do
    context '@data_items' do
      subject(:data_items) { collection.instance_variable_get(:@data_items) }

      it 'assigns an array of data items' do
        is_expected.to be_a Array
        is_expected.to_not be_empty
      end

      it 'adds one data item for each record in csv file' do
        expect(data_items.size).to eq 33
      end

      it 'each data_item is a TransferBrainDataItem' do
        expect(data_items.first).to be_a Claim::TransferBrainDataItem
      end
    end

    context '@collection_hash' do
      subject(:collection_hash) { collection.instance_variable_get(:@collection_hash) }

      it 'assigns a hash' do
        is_expected.to be_a Hash
        is_expected.to_not be_empty
      end

      it 'assigns deep nested hash with expected keys' do
        expect(collection_hash.dig('new', true, 10, '*').keys).to include(:validity, :transfer_fee_full_name, :allocation_type, :bill_scenario, :ppe_required, :days_claimable)
      end

      it 'adds one nested hash for each data item' do
        expect(collection_hash.all_values_for(:validity).size).to eq 33
      end
    end
  end

  describe '#to_h' do
    subject { collection.to_h }
    it { is_expected.to be_a Hash }
    it { is_expected.to match_hash(data_item_collection_hash) }
  end

  describe '#data_item_for' do
    subject { collection.data_item_for(detail) }

    context 'when given valid details with a mappable case conclusion id' do
      let(:detail) { with_specific_mapping }

      it 'returns a valid data item' do
        is_expected.to include({ :validity => true })
      end
    end

    context 'when given valid details with a wildcard case conclusion id' do
      let(:detail) { with_wildcard_mapping }

      it 'returns a valid data item' do
        is_expected.to include({ :validity => true })
      end
    end

    context 'when given and invalid combination of details' do
      let(:detail) { with_invalid_combo }
      it { is_expected.to be_nil }
    end
  end

  describe '#transfer_fee_full_name' do
    subject(:call) { collection.transfer_fee_full_name(detail) }

    context 'when given valid details with a mappable case conclusion id' do
      let(:detail) { with_specific_mapping }

      it 'returns transfer fee full name for matching' do
        is_expected.to eq 'up to and including PCMH transfer (new) - guilty plea'
      end
    end

    context 'when given valid details with a wildcard case conclusion id' do
      let(:detail) { with_wildcard_mapping }

      it 'returns transfer fee full name for matching detail' do
        is_expected.to eq 'elected case - up to and including PCMH transfer (new)'
      end
    end
  end

  describe '#allocation_type' do
    subject(:call) { collection.allocation_type(detail) }

    context 'when given valid details with a mappable case conclusion id' do
      let(:detail) { with_specific_mapping }

      it 'returns allocation type for matching detail' do
        is_expected.to eq 'Grad'
      end
    end

    context 'when given valid details with a wildcard case conclusion id' do
      let(:detail) { with_wildcard_mapping }

      it 'returns allocation type for matching detail' do
        is_expected.to eq 'Fixed'
      end
    end
  end

  describe '#bill_scenario' do
    subject(:call) { collection.bill_scenario(detail) }

    context 'when given valid details with a mappable case conclusion id' do
      let(:detail) { with_specific_mapping }

      it 'returns bill scenario for matching detail' do
        is_expected.to eq 'ST3TS1T2'
      end
    end

    context 'when given valid details with a wildcard case conclusion id' do
      let(:detail) { with_wildcard_mapping }

      it 'returns bill scenario for matching detail' do
        is_expected.to eq 'ST4TS0T3'
      end
    end
  end

  describe '#ppe_required' do
    subject(:call) { collection.ppe_required(detail) }

    context 'when given valid details with a mappable case conclusion id' do
      let(:detail) { with_specific_mapping }

      it 'returns boolean' do
        is_expected.to be_in(%w[TRUE FALSE])
      end
    end

    context 'when given valid details with a wildcard case conclusion id' do
      let(:detail) { with_wildcard_mapping }

      it 'returns boolean' do
        is_expected.to be_in(%w[TRUE FALSE])
      end
    end
  end

  describe '#days_claimable' do
    subject(:call) { collection.days_claimable(detail) }

    context 'when given valid details with a mappable case conclusion id' do
      let(:detail) { with_specific_mapping }

      it 'returns boolean' do
        is_expected.to be_in(%w[TRUE FALSE])
      end
    end

    context 'when given valid details with a wildcard case conclusion id' do
      let(:detail) { with_wildcard_mapping }

      it 'returns boolean' do
        is_expected.to be_in(%w[TRUE FALSE])
      end
    end
  end

  describe '#detail_valid?' do
    subject(:call) { collection.detail_valid?(detail) }

    context 'when given valid details with a mappable case conclusion id' do
      let(:detail) { with_specific_mapping }
      it { is_expected.to be true }
    end

    context 'when given valid details with a wildcard case conclusion id' do
      let(:detail) { with_wildcard_mapping }
      it { is_expected.to be true }
    end

    context 'when given and invalid combination of details' do
      let(:detail) { with_invalid_combo }
      it { is_expected.to be false }
    end
  end

  describe '#valid_transfer_stage_ids' do
    context 'new litigator type with elected case' do
      it 'returns a list of valid transfer_stage_ids' do
        expect(described_class.instance.valid_transfer_stage_ids('new', true)).to eq([10, 20, 50])
      end
    end

    context 'new litigator type and non elected case' do
      it 'returns a list of valid transfer_stage_ids' do
        expect(described_class.instance.valid_transfer_stage_ids('new', false)).to eq([10, 20, 30, 40, 50, 60, 70])
      end
    end
  end

  describe '#valid_case_conclusion_ids' do
    context 'new litigator type with elected case and transfer stage id of 20' do
      it 'returns a full set of conclusiont ids' do
        expect(described_class.instance.valid_case_conclusion_ids('new', true, 20)).to eq([10, 20, 30, 40, 50])
      end
    end

    context 'new litigator type with elected case and transfer stage id of 20' do
      it 'returns a limited set of conclusion ids' do
        expect(described_class.instance.valid_case_conclusion_ids('new', false, 20)).to eq([10, 30])
      end
    end
  end
end
