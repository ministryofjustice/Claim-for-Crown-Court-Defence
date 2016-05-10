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
end
