require 'rails_helper'

module Claim
  describe TransferBrain do
    describe '.transfer_stage_by_id' do

      it 'returns the name of the transfer_stage with that id' do
        expect(TransferBrain.transfer_stage_by_id(50)).to eq 'Transfer before retrial'
      end

      it 'raises if invalid id given' do
        expect{ TransferBrain.transfer_stage_by_id(55) }.to raise_error ArgumentError, 'No such transfer stage id: 55'
      end
    end

    describe '.transfer_stage_id' do
      it 'returns the id of the transfer stage with the given name' do
        expect(TransferBrain.transfer_stage_id('Transfer before retrial')).to eq 50
      end

      it 'raises if no such transfer stage with the given name' do
        expect{ TransferBrain.transfer_stage_id('xxx') }.to raise_error ArgumentError, "No such transfer stage: 'xxx'"
      end
    end

    describe '.transfer_stage_ids' do
      it 'returns transfer stage ids' do
        expect(TransferBrain.transfer_stage_ids).to eq( [ 10, 20, 30, 40, 50, 60 ])
      end
    end

    describe '.case_conclusion_by_id' do
      it 'returns the name of the case conclusion with that id' do
        expect(TransferBrain.case_conclusion_by_id(30)).to eq 'Cracked'
      end

      it 'raises if invalid id given' do
        expect{ TransferBrain.case_conclusion_by_id(55) }.to raise_error ArgumentError, 'No such case conclusion id: 55'
      end
    end

    describe '.case_conclusion_id' do
      it 'returns the id of the case conclusion with the given name' do
        expect(TransferBrain.case_conclusion_id('Retrial')).to eq 20
      end

      it 'raises if no such case conclusion with the given name' do
        expect{ TransferBrain.case_conclusion_id('xxx') }.to raise_error ArgumentError, "No such case conclusion: 'xxx'"
      end
    end
  end


end