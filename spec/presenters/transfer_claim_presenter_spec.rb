require 'rails_helper'

RSpec.describe Claim::TransferClaimPresenter do

  let(:claim) { instance_double(Claim::TransferClaim, transfer_detail: double) }
  let(:presenter) { Claim::TransferClaimPresenter.new(claim, view) }

  it { expect(presenter).to be_instance_of(Claim::TransferClaimPresenter) }
  it { expect(presenter).to be_kind_of(Claim::BaseClaimPresenter) }

  it 'should have expenses' do
     expect(presenter.can_have_expenses?).to eq(true)
  end

  it 'should have disbursements' do
    expect(presenter.can_have_disbursements?).to eq(true)
  end

  let(:case_conclusions) do
    {
      '10' => 'Trial',
      '20' => 'Retrial',
      '30' => 'Cracked',
      '40' => 'Cracked before retrial',
      '50' => 'Guilty plea'
    }
  end

  context '#case_conclusions' do
    it 'returns a has of case conclusion descriptions and ids' do
      expect(presenter.case_conclusions).to match case_conclusions
    end
  end

  context '#transfer_detail_summary' do
    context 'for transfer details NOT requiring a conclusion' do
      let(:claim) { create :transfer_claim, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: nil }
      it 'should return a string of expected values' do
        expect(presenter.transfer_detail_summary).to eql 'elected case - up to and including PCMH transfer (new)'
      end
    end

    context 'for transfer details NOT requiring a conclusion and from original litigator' do
      let(:claim) { create :transfer_claim, litigator_type: 'original', elected_case: false, transfer_stage_id: 40, case_conclusion_id: nil }
      it 'should return a string of expected values' do
        expect(presenter.transfer_detail_summary).to eql 'transfer after trial and before sentence hearing (org)'
      end
    end

    context 'for transfer details requiring a conclusion' do
      let(:claim) { create :transfer_claim, litigator_type: 'new', elected_case: false, transfer_stage_id: 20, case_conclusion_id: 30 }
      it 'should return a string of expected values' do
        expect(presenter.transfer_detail_summary).to eql 'before trial transfer (new) - cracked'
      end
    end

    context 'for incomplete transfer details' do
      let(:claim) { create :transfer_claim, litigator_type: nil, elected_case: nil, transfer_stage_id: nil, case_conclusion_id: nil }
      it 'should return blank string' do
        expect(presenter.transfer_detail_summary).to be_blank
      end
    end
  end

  context 'descriptor methods' do
    let(:claim) { create :transfer_claim, litigator_type: 'new', elected_case: false, transfer_stage_id: 20, transfer_date: Date.parse('2015-05-21'), case_conclusion_id: 30 }
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
      expect(presenter.transfer_date).to eql '21/05/2015'
    end
    it '#case_conclusion_description' do
      expect(presenter.case_conclusion_description).to eql 'Cracked'
    end
  end

end
