require 'rails_helper'

RSpec.describe Claim::TransferBrain::DataItem do
  subject(:data_item) { described_class.new(**data) }

  describe '#to_h' do
    subject { data_item.to_h }

    let(:data) do
      {
        litigator_type: 'NEW',
        elected_case: 'FALSE',
        transfer_stage: 'Up to and including PCMH transfer',
        conclusion: 'Guilty plea',
        valid: 'TRUE',
        transfer_fee_full_name: 'up to and including PCMH transfer (new) - guilty plea',
        allocation_type: 'Grad',
        bill_scenario: 'ST3TS1T2',
        ppe_required: 'FALSE',
        days_claimable: 'FALSE'
      }
    end

    let(:expected_hash) do
      {
        'new' => {
          false => {
            10 => {
              50 => {
                validity: true,
                transfer_fee_full_name: 'up to and including PCMH transfer (new) - guilty plea',
                allocation_type: 'Grad',
                bill_scenario: 'ST3TS1T2',
                ppe_required: 'FALSE',
                days_claimable: 'FALSE'
              }
            }
          }
        }
      }
    end

    it 'returns a hash' do
      is_expected.to be_a(Hash)
    end

    it 'returns expected nested key value pairs' do
      is_expected.to eql expected_hash
    end
  end

  describe '#litigator_type' do
    subject { data_item.litigator_type }

    context 'with litigator type in lower case' do
      let(:data) { { litigator_type: 'new' } }

      it { is_expected.to eq 'new' }
    end

    context 'with litigator type in capitals' do
      let(:data) { { litigator_type: 'NEW' } }

      it { is_expected.to eq 'new' }
    end

    context 'with litigator type missing' do
      let(:data) { {} }

      it { is_expected.to be_nil }
    end

    context 'with litigator type explicitly set to nil' do
      let(:data) { { litigator_type: nil } }

      it { is_expected.to be_nil }
    end
  end

  describe '#elected_case' do
    subject { data_item.elected_case }

    context 'with true elected case' do
      let(:data) { { elected_case: 'TRUE' } }

      it { is_expected.to be true }
    end

    context 'with false elected case' do
      let(:data) { { elected_case: 'FALSE' } }

      it { is_expected.to be false }
    end
  end

  describe '#transfer_stage_id' do
    subject { data_item.transfer_stage_id }

    context 'with the transfer stage; During trial transfer' do
      let(:data) { { transfer_stage: 'During trial transfer' } }

      it { is_expected.to eq 30 }
    end
  end

  describe '#case_conclusion_id' do
    subject { data_item.case_conclusion_id }

    context 'with the conclusion; Retrial' do
      let(:data) { { conclusion: 'Retrial' } }

      it { is_expected.to eq 20 }
    end

    context 'with a nil conclusion' do
      let(:data) { { conclusion: nil } }

      it { is_expected.to eq '*' }
    end
  end

  describe '#validity' do
    subject { data_item.validity }

    context 'with valid set to TRUE' do
      let(:data) { { valid: 'TRUE' } }

      it { is_expected.to be true }
    end

    context 'with valid set to FALSE' do
      let(:data) { { valid: 'FALSE' } }

      it { is_expected.to be false }
    end
  end

  describe '#==' do
    let(:elected_item) do
      described_class.new(
        litigator_type:,
        elected_case: 'TRUE',
        transfer_stage:,
        conclusion: 'Guilty plea',
        valid: 'TRUE',
        transfer_fee_full_name: 'elected case - up to and including PCMH transfer (new)',
        allocation_type: 'Fixed',
        bill_scenario: 'ST4TS0T3',
        ppe_required: 'FALSE',
        days_claimable: 'FALSE'
      )
    end
    let(:non_elected_item) do
      described_class.new(
        litigator_type:,
        elected_case: 'FALSE',
        transfer_stage:,
        conclusion: 'Cracked',
        valid: 'TRUE',
        transfer_fee_full_name: 'up to and including PCMH transfer (new)',
        allocation_type: 'Grad',
        bill_scenario: 'ST3TS1T3',
        ppe_required: 'FALSE',
        days_claimable: 'FALSE'
      )
    end
    let(:test_item) do
      described_class.new(
        litigator_type:,
        elected_case:,
        transfer_stage:,
        conclusion:,
        valid: 'TRUE',
        transfer_fee_full_name: 'elected case - up to and including PCMH transfer (new)',
        allocation_type:,
        bill_scenario: 'ST4TS0T3',
        ppe_required: 'FALSE',
        days_claimable: 'FALSE',
        claim:
      )
    end

    context 'with an ECNP Before trial transfer (new) claim' do
      let(:litigator_type) { 'NEW' }
      let(:transfer_stage) { 'Before trial transfer' }
      let(:elected_case) { 'TRUE' }
      let(:allocation_type) { 'FIXED' }
      let(:conclusion) { nil }

      context 'with scheme 9 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

        it { expect(elected_item).to eq test_item }
        it { expect(non_elected_item).not_to eq test_item }
      end

      context 'with scheme 10 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

        it { expect(elected_item).not_to eq test_item }
        it { expect(non_elected_item).to eq test_item }
      end
    end

    context 'with an ECNP Before trial transfer (org) claim' do
      let(:litigator_type) { 'ORIGINAL' }
      let(:transfer_stage) { 'Before trial transfer' }
      let(:elected_case) { 'TRUE' }
      let(:allocation_type) { 'FIXED' }
      let(:conclusion) { nil }

      context 'with scheme 9 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

        it { expect(elected_item).to eq test_item }
        it { expect(non_elected_item).not_to eq test_item }
      end

      context 'with scheme 10 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

        it { expect(elected_item).not_to eq test_item }
        it { expect(non_elected_item).to eq test_item }
      end
    end

    context 'with an ECNP transfer before retrial transfer (new) claim' do
      let(:litigator_type) { 'NEW' }
      let(:transfer_stage) { 'Transfer before retrial' }
      let(:elected_case) { 'TRUE' }
      let(:allocation_type) { 'FIXED' }
      let(:conclusion) { nil }

      context 'with scheme 9 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

        it { expect(elected_item).to eq test_item }
        it { expect(non_elected_item).not_to eq test_item }
      end

      context 'with scheme 10 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

        it { expect(elected_item).not_to eq test_item }
        it { expect(non_elected_item).to eq test_item }
      end
    end

    context 'with an ECNP transfer before retrial transfer (org) claim' do
      let(:litigator_type) { 'ORIGINAL' }
      let(:transfer_stage) { 'Transfer before retrial' }
      let(:elected_case) { 'TRUE' }
      let(:allocation_type) { 'FIXED' }
      let(:conclusion) { nil }

      context 'with scheme 9 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

        it { expect(elected_item).to eq test_item }
        it { expect(non_elected_item).not_to eq test_item }
      end

      context 'with scheme 10 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

        it { expect(elected_item).not_to eq test_item }
        it { expect(non_elected_item).to eq test_item }
      end
    end

    context 'with an ECNP up to and including PCMH transfer (new) claim' do
      let(:litigator_type) { 'NEW' }
      let(:transfer_stage) { 'Up to and including PCMH transfer' }
      let(:elected_case) { 'TRUE' }
      let(:allocation_type) { 'FIXED' }
      let(:conclusion) { nil }

      context 'with scheme 9 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

        it { expect(elected_item).to eq test_item }
        it { expect(non_elected_item).not_to eq test_item }
      end

      context 'with scheme 10 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

        it { expect(elected_item).not_to eq test_item }
        it { expect(non_elected_item).to eq test_item }
      end
    end

    context 'with an ECNP up to and including PCMH transfer (org) claim' do
      let(:litigator_type) { 'ORIGINAL' }
      let(:transfer_stage) { 'Up to and including PCMH transfer' }
      let(:elected_case) { 'TRUE' }
      let(:allocation_type) { 'FIXED' }
      let(:conclusion) { nil }

      context 'with scheme 9 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

        it { expect(elected_item).to eq test_item }
        it { expect(non_elected_item).not_to eq test_item }
      end

      context 'with scheme 10 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

        it { expect(elected_item).not_to eq test_item }
        it { expect(non_elected_item).to eq test_item }
      end
    end

    context 'with an up to and including PCMH transfer (org) claim' do
      let(:litigator_type) { 'ORIGINAL' }
      let(:transfer_stage) { 'Up to and including PCMH transfer' }
      let(:elected_case) { 'FALSE' }
      let(:allocation_type) { 'GRAD' }
      let(:conclusion) { 'Cracked' }

      context 'with scheme 9 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

        it { expect(non_elected_item).to eq test_item }
      end

      context 'with scheme 10 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

        it { expect(non_elected_item).to eq test_item }
      end
    end
  end
end
