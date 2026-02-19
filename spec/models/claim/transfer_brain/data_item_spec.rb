require 'rails_helper'

RSpec.describe Claim::TransferBrain::DataItem do
  subject(:data_item) { described_class.new(**data) }

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
    shared_context 'with transfer claim data items' do
      let(:default_values) do
        {
          litigator_type:,
          transfer_stage:,
          valid: 'TRUE',
          transfer_fee_full_name: 'test fee full name',
          bill_scenario: 'BILLSCEN',
          ppe_required: 'FALSE',
          days_claimable: 'FALSE'
        }
      end
      let(:elected_item) do
        described_class.new(
          **default_values,
          elected_case: 'TRUE', conclusion: 'Guilty plea', allocation_type: 'Fixed'
        )
      end
      let(:non_elected_item) do
        described_class.new(
          **default_values,
          elected_case: 'FALSE', conclusion: 'Cracked', allocation_type: 'Grad'
        )
      end
      let(:test_item) do
        described_class.new(
          **default_values,
          elected_case:, conclusion:, allocation_type:, claim:
        )
      end
    end

    shared_examples 'non-ECNP transfer data item mappings' do
      include_context 'with transfer claim data items'
      let(:allocation_type) { 'GRAD' }
      let(:conclusion) { 'Cracked' }

      context 'with scheme 9 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

        it { expect(non_elected_item).to eq test_item }
      end

      context 'with scheme 9a elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9a: true) }

        it { expect(non_elected_item).to eq test_item }
      end

      context 'with scheme 10 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

        it { expect(non_elected_item).to eq test_item }
      end

      context 'with scheme 11 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_11: true) }

        before { travel_to(Settings.lgfs_scheme_11_release_date.beginning_of_day) }

        it { expect(non_elected_item).to eq test_item }
      end
    end

    shared_examples 'ECNP transfer data item mappings' do
      include_context 'with transfer claim data items'
      let(:allocation_type) { 'FIXED' }
      let(:conclusion) { nil }

      context 'with scheme 9 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9: true) }

        it { expect(elected_item).to eq test_item }
        it { expect(non_elected_item).not_to eq test_item }
      end

      context 'with scheme 9a elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_9a: true) }

        it { expect(elected_item).not_to eq test_item }
        it { expect(non_elected_item).to eq test_item }
      end

      context 'with scheme 10 elected case claims' do
        let(:claim) { create(:transfer_claim, create_defendant_and_rep_order_for_scheme_10: true) }

        it { expect(elected_item).not_to eq test_item }
        it { expect(non_elected_item).to eq test_item }
      end
    end

    shared_examples 'ECNP transfer stages' do
      context 'with Before trial transfer (new) claim' do
        let(:transfer_stage) { 'Before trial transfer' }

        include_examples 'ECNP transfer data item mappings'
      end

      context 'with transfer before retrial transfer (new) claim' do
        let(:transfer_stage) { 'Transfer before retrial' }

        include_examples 'ECNP transfer data item mappings'
      end

      context 'with up to and including PCMH transfer (new) claim' do
        let(:transfer_stage) { 'Up to and including PCMH transfer' }

        include_examples 'ECNP transfer data item mappings'
      end
    end

    context 'with ECNP claim' do
      let(:elected_case) { 'TRUE' }

      context 'with a new litigator' do
        let(:litigator_type) { 'NEW' }

        include_examples 'ECNP transfer stages'
      end

      context 'with an original litigator' do
        let(:litigator_type) { 'ORIGINAL' }

        include_examples 'ECNP transfer stages'
      end
    end

    context 'with an up to and including PCMH transfer (org) claim' do
      let(:litigator_type) { 'ORIGINAL' }
      let(:transfer_stage) { 'Up to and including PCMH transfer' }
      let(:elected_case) { 'FALSE' }

      include_examples 'non-ECNP transfer data item mappings'
    end
  end
end
