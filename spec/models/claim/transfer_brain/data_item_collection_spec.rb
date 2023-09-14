require 'rails_helper'

RSpec.shared_examples 'transfer claim elected case bill scenario mapping' do
  context 'with an "elected case - up to and including PCMH transfer (new)" case' do
    let(:detail) do
      build(:transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: nil,
                              claim:)
    end

    it { is_expected.to eq bill_scenario_mapping[:up_to_and_including_pcmh_transfer_new] }
  end

  context 'with an "elected case - up to and including PCMH transfer (org)" case' do
    let(:detail) do
      build(:transfer_detail, litigator_type: 'original', elected_case: true, transfer_stage_id: 10,
                              case_conclusion_id: nil, claim:)
    end

    it { is_expected.to eq bill_scenario_mapping[:up_to_and_including_pcmh_transfer_org] }
  end

  context 'with an "elected case - before trial transfer (new)" case' do
    let(:detail) do
      build(:transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 20, case_conclusion_id: nil,
                              claim:)
    end

    it { is_expected.to eq bill_scenario_mapping[:before_trial_transfer_new] }
  end

  context 'with an "elected case - before trial transfer (org)" case' do
    let(:detail) do
      build(:transfer_detail, litigator_type: 'original', elected_case: true, transfer_stage_id: 20,
                              case_conclusion_id: nil, claim:)
    end

    it { is_expected.to eq bill_scenario_mapping[:before_trial_transfer_org] }
  end

  context 'with an "elected case - transfer before retrial (new)" case' do
    let(:detail) do
      build(:transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 50, case_conclusion_id: nil,
                              claim:)
    end

    it { is_expected.to eq bill_scenario_mapping[:transfer_before_retrial_new] }
  end

  context 'with an "elected case - transfer before retrial (org)" case' do
    let(:detail) do
      build(:transfer_detail, litigator_type: 'original', elected_case: true, transfer_stage_id: 50,
                              case_conclusion_id: nil, claim:)
    end

    it { is_expected.to eq bill_scenario_mapping[:transfer_before_retrial_org] }
  end
end

RSpec.describe Claim::TransferBrain::DataItemCollection do
  include TransferBrainHelpers

  subject(:collection) { described_class.instance }

  # specific mapping: where there is a case conclusion id specific mapping (case conclusion is relevant)
  # wildcard mapping: where there is mapping for any case conclusion id, using "*" key (i.e. case conclusion is irrelevant)
  let(:with_wildcard_mapping) { build(:transfer_detail, :with_wildcard_mapping) }
  let(:with_specific_mapping) { build(:transfer_detail, :with_specific_mapping) }

  describe '#data_items' do
    subject(:data_items) { collection.send(:data_items) }

    it { is_expected.to be_an Array }
    it { is_expected.not_to be_empty }

    it 'adds one data item for each record in csv file' do
      expect(data_items.size).to eq 33
    end

    it 'each data_item is a TransferBrain::DataItem' do
      expect(data_items.first).to be_a Claim::TransferBrain::DataItem
    end
  end

  describe '#data_item_for' do
    subject(:data_item) { collection.data_item_for(detail) }

    context 'when given valid details with a mappable case conclusion id' do
      let(:detail) { with_specific_mapping }

      it 'returns a valid data item' do
        expect(data_item.validity).to be_truthy
      end
    end

    context 'when given valid details with a wildcard case conclusion id' do
      let(:detail) { with_wildcard_mapping }

      it 'returns a valid data item' do
        expect(data_item.validity).to be_truthy
      end
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

    context 'with a scheme 9 claim' do
      let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

      it_behaves_like 'transfer claim elected case bill scenario mapping' do
        let(:bill_scenario_mapping) do
          {
            up_to_and_including_pcmh_transfer_new: 'ST4TS0T3',
            up_to_and_including_pcmh_transfer_org: 'ST4TS0T2',
            before_trial_transfer_new: 'ST4TS0T5',
            before_trial_transfer_org: 'ST4TS0T4',
            transfer_before_retrial_new: 'ST4TS0T7',
            transfer_before_retrial_org: 'ST4TS0T6'
          }
        end
      end
    end

    context 'with a scheme 10 claim' do
      let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

      include_examples 'transfer claim elected case bill scenario mapping' do
        let(:bill_scenario_mapping) do
          {
            up_to_and_including_pcmh_transfer_new: 'ST3TS1T3',
            up_to_and_including_pcmh_transfer_org: 'ST2TS1T0',
            before_trial_transfer_new: 'ST3TS2T3',
            before_trial_transfer_org: 'ST2TS2T0',
            transfer_before_retrial_new: 'ST3TS4T9',
            transfer_before_retrial_org: 'ST2TS4T0'
          }
        end
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

    context 'with new litigator on an elected case' do
      let(:detail) do
        build(
          :transfer_detail,
          litigator_type: 'new',
          elected_case: true,
          case_conclusion_id: 10,
          transfer_stage_id:
        )
      end

      context 'when "Up to and including PCMH transfer"' do
        let(:transfer_stage_id) { 10 }

        it { is_expected.to be_truthy }
      end

      context 'when "Before trial transfer"' do
        let(:transfer_stage_id) { 20 }

        it { is_expected.to be_truthy }
      end

      context 'when "During trial transfer"' do
        let(:transfer_stage_id) { 30 }

        it { is_expected.to be_falsey }
      end

      context 'when "Transfer after trial and before sentence hearing"' do
        let(:transfer_stage_id) { 40 }

        it { is_expected.to be_falsey }
      end

      context 'when "Transfer during retrial"' do
        let(:transfer_stage_id) { 60 }

        it { is_expected.to be_falsey }
      end

      context 'when "Transfer after retrial and before sentence hearing"' do
        let(:transfer_stage_id) { 70 }

        it { is_expected.to be_falsey }
      end
    end

    context 'with new litigator on a non elected case' do
      let(:detail) do
        build(
          :transfer_detail,
          litigator_type: 'new',
          elected_case: false,
          case_conclusion_id:,
          transfer_stage_id:
        )
      end

      context 'with cracked trial "Before trial transfer"' do
        let(:case_conclusion_id) { 30 }
        let(:transfer_stage_id) { 20 }

        it { is_expected.to be_truthy }
      end

      context 'with retrial "During trial transfer"' do
        let(:case_conclusion_id) { 20 }
        let(:transfer_stage_id) { 30 }

        it { is_expected.to be_truthy }
      end

      context 'with cracked before retrial "Transfer before reretrial"' do
        let(:case_conclusion_id) { 40 }
        let(:transfer_stage_id) { 50 }

        it { is_expected.to be_truthy }
      end
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

    context 'new litigator type with not-elected case and transfer stage id of 20' do
      it 'returns a limited set of conclusion ids' do
        expect(described_class.instance.valid_case_conclusion_ids('new', false, 20)).to eq([10, 30])
      end
    end
  end
end
