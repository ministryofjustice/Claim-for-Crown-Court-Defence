require 'rails_helper'

describe Claim::TransferDetailPresenter do

  let(:claim) { instance_double(Claim::TransferClaim, transfer_detail: double) }
  let(:presenter) { Claim::TransferDetailPresenter.new(claim.transfer_detail, view) }

  let(:transfer_stages) do
    {
      '10' => 'Up to and including PCMH transfer',
      '20' => 'Before trial transfer',
      '30' => 'During trial transfer',
      '40' => 'Transfer after trial and before sentence hearing',
      '50' => 'Transfer before retrial',
      '60' => 'Transfer during retrial',
      '70' => 'Transfer after retrial and before sentence hearing'
    }
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

  context '#transfer_stages' do
    it 'returns a hash of transfer stage descriptions and ids' do
      expect(presenter.transfer_stages).to match transfer_stages
    end
  end

  context '#case_conclusions' do
    it 'returns a has of case conclusion descriptions and ids' do
      expect(presenter.case_conclusions).to match case_conclusions
    end
  end

  context '#stringified_summary' do

    #
    # TEMPLATE: '{if elected_case=true, 'elected case -'} {transfer_stage_id description} {(litigator_type abbrev ie. new|org)} - (case_conclusion_id description if exists)'
    #

    context 'for transfer details NOT requiring a conclusion' do
      let(:claim) { create :transfer_claim, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: nil }
      it 'should return a string of expected values' do
        expect(presenter.stringified_summary).to eql 'elected case - Up to and including PCMH transfer (new)'
      end
    end

    context 'for transfer details NOT requiring a conclusion and from original litigator' do
      let(:claim) { create :transfer_claim, litigator_type: 'original', elected_case: false, transfer_stage_id: 40, case_conclusion_id: nil }
      it 'should return a string of expected values' do
        expect(presenter.stringified_summary).to eql 'Transfer after trial and before sentence hearing (org)'
      end
    end

    context 'for transfer details requiring a conclusion' do
      let(:claim) { create :transfer_claim, litigator_type: 'new', elected_case: false, transfer_stage_id: 20, case_conclusion_id: 30 }
      it 'should return a string of expected values' do
        expect(presenter.stringified_summary).to eql 'Before trial transfer (new) - cracked'
      end
    end

    context 'for incomplete transfer details' do
      let(:claim) { create :transfer_claim, litigator_type: nil, elected_case: nil, transfer_stage_id: nil, case_conclusion_id: nil }
      it 'should return a string of expected values' do
        expect(presenter.stringified_summary).to eql 'Incomplete transfer details'
      end
    end

  end
end
