require 'rails_helper'

RSpec.describe Claim::TransferClaimPresenter, type: :presenter do
  subject(:presenter) { described_class.new(claim, view) }

  let(:claim) { build(:transfer_claim) }

  it { expect(presenter).to be_instance_of(described_class) }
  it { expect(presenter).to be_a(Claim::BaseClaimPresenter) }

  specify { expect(presenter.pretty_type).to eq('LGFS Transfer') }
  specify { expect(presenter.type_identifier).to eq('lgfs_transfer') }

  describe '#raw_transfer_fees_total' do
    context 'when the transfer fee is nil' do
      let(:claim) { build(:transfer_claim, transfer_fee: nil) }

      specify { expect(presenter.raw_transfer_fees_total).to eq(0) }
    end

    context 'when the transfer fee is set' do
      let(:claim) { build(:transfer_claim, transfer_fee:) }

      context 'when amount is not set' do
        let(:transfer_fee) { build(:transfer_fee, amount: nil) }

        specify { expect(presenter.raw_transfer_fees_total).to eq(0) }
      end

      context 'when amount is set' do
        let(:transfer_fee) { build(:transfer_fee, amount: 42.5) }

        specify { expect(presenter.raw_transfer_fees_total).to eq(42.5) }
      end
    end
  end

  describe '#display_days?' do
    subject { presenter.display_days? }

    context 'with a transfer case' do
      let(:claim) { build(:transfer_claim, transfer_fee: nil) }

      it { is_expected.to be true }
    end
  end

  describe '#summary_sections' do
    subject { presenter.summary_sections }

    let(:expected_sections) do
      {
        transfer_detail: :transfer_fee_details,
        case_details: :case_details,
        defendants: :defendants,
        offence_details: :offence_details,
        transfer_fee: :transfer_fees,
        misc_fees: :miscellaneous_fees,
        disbursements: :disbursements,
        expenses: :travel_expenses,
        supporting_evidence: :supporting_evidence,
        additional_information: :supporting_evidence
      }
    end

    it { is_expected.to eq expected_sections }
  end

  describe '#conclusion_required?' do
    subject { presenter.conclusion_required? }

    let(:claim) { build(:transfer_claim, transfer_detail: detail) }

    context 'when acting is set to `Up to and including PCMH transfer`' do
      let(:detail) { build(:transfer_detail, litigator_type: 'new') }

      it { is_expected.to be true }
    end

    context 'when acting is set to `Transfer after trial and before sentence hearing`' do
      let(:detail) { build(:transfer_detail, litigator_type: 'new', transfer_stage_id: 40) }

      it { is_expected.to be false }
    end
  end

  describe 'calculate #transfer_fees' do
    before do
      allow(presenter).to receive(:raw_transfer_fees_total).and_return 10.0
      allow(claim).to receive_messages(created_at: Time.zone.today, apply_vat?: true)
    end

    it '#raw_transfer_fees_vat' do
      expect(presenter.raw_transfer_fees_vat).to eq(2.0)
    end

    it 'returns #raw_transfer_fees_gross' do
      allow(presenter).to receive(:raw_transfer_fees_vat).and_return 2.0
      expect(presenter.raw_transfer_fees_gross).to eq(12.0)
    end

    it 'returns #transfer_fees_vat with the associated currency' do
      expect(presenter.transfer_fees_vat).to eq('£2.00')
    end

    it 'returns #transfer_fees_gross with the associated currency' do
      expect(presenter.transfer_fees_gross).to eq('£12.00')
    end
  end

  describe '#can_have_disbursements?' do
    subject { presenter.can_have_disbursements? }

    it { is_expected.to be_truthy }
  end

  describe '#case_conclusions' do
    let(:case_conclusions) do
      {
        '10' => 'Trial',
        '20' => 'Retrial',
        '30' => 'Cracked',
        '40' => 'Cracked before retrial',
        '50' => 'Guilty plea'
      }
    end

    it 'returns a has of case conclusion descriptions and ids' do
      expect(presenter.case_conclusions).to match(case_conclusions)
    end
  end

  describe '#transfer_detail_summary' do
    context 'with transfer details NOT requiring a conclusion' do
      let(:claim) do
        create(
          :transfer_claim,
          litigator_type: 'new',
          elected_case: true,
          transfer_stage_id: 10,
          case_conclusion_id: nil
        )
      end

      it 'returns a string of expected values' do
        expect(presenter.transfer_detail_summary).to eql 'Elected case - up to and including PCMH transfer (new)'
      end
    end

    context 'with transfer details NOT requiring a conclusion and from original litigator' do
      let(:claim) do
        create(
          :transfer_claim,
          litigator_type: 'original',
          elected_case: false,
          transfer_stage_id: 40,
          case_conclusion_id: nil
        )
      end

      it 'returns a string of expected values' do
        expect(presenter.transfer_detail_summary).to eql 'Transfer after trial and before sentence hearing (org)'
      end
    end

    context 'with transfer details requiring a conclusion' do
      let(:claim) do
        create(
          :transfer_claim,
          litigator_type: 'new',
          elected_case: false,
          transfer_stage_id: 20,
          case_conclusion_id: 30
        )
      end

      it 'returns a string of expected values' do
        expect(presenter.transfer_detail_summary).to eql 'Before trial transfer (new) - cracked'
      end
    end

    context 'with incomplete transfer details' do
      let(:claim) do
        create(:transfer_claim, litigator_type: nil, elected_case: nil, transfer_stage_id: nil, case_conclusion_id: nil)
      end

      it 'returns blank string' do
        expect(presenter.transfer_detail_summary).to be_blank
      end
    end
  end

  describe 'descriptor methods' do
    let(:claim) do
      create(
        :transfer_claim,
        litigator_type: 'new',
        elected_case: false,
        transfer_stage_id: 20,
        transfer_date: Date.parse('2014-05-21'),
        case_conclusion_id: 30
      )
    end

    it '#litigator_type_description' do
      expect(presenter.litigator_type_description).to eql 'New'
    end

    it '#elected_case_description' do
      expect(presenter.elected_case_description).to eql 'No'
    end

    it '#transfer_stage_description' do
      expect(presenter.transfer_stage_description).to eql 'Before trial transfer'
    end

    it '#transfer_date' do
      expect(presenter.transfer_date).to eql '21/05/2014'
    end

    it '#case_conclusion_description' do
      expect(presenter.case_conclusion_description).to eql 'Cracked'
    end
  end
end
