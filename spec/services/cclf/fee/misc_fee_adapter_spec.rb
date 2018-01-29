require 'rails_helper'
require 'spec_helper'

module CCLF
  module Fee
    describe MiscFeeAdapter, type: :adapter do
      let(:fee) { instance_double('fee') }

      # For a fee type the misc fee maps to a given CCLF bill type and sub type
      # however the bill scenario and "formula"* will depend on the
      # case type and litigator claim type.
      # *nb: formula is used CCLF-side only and maps to whether to use quantity or amount???
      #
      BILL_TYPE_MAPPINGS = {
        MIUPL: [nil, nil], # Case uplift - no equivalent in LGFS - to be removed from app too?!
        MICJA: ['OTHER', 'COST_JUDGE_FEE'], # Costs judge application
        MICJP: ['OTHER', 'COST_JUD_EXP'], # Costs judge preparation
        MIEVI: ['EVID_PROV_FEE', 'EVID_PROV_FEE'], # Evidence provision fee
        MISPF: ['FEE_SUPPLEMENT', 'SPECIAL_PREP'] # Special preparation fee
      }.freeze

      BILL_SCENARIO_MAPPINGS = {
        FXACV: 'ST1TS0T5', # Appeal against conviction
        FXASE: 'ST1TS0T6', # Appeal against sentence
        FXCBR: 'ST3TS3TB', # Breach of Crown Court order
        FXCSE: 'ST1TS0T7', # Committal for Sentence
        FXCON: 'ST1TS0T8', # Contempt
        FXENP: 'ST4TS0T1', # Elected cases not proceeded
        FXH2S: 'ST1TS0TC', # Hearing subsequent to sentence
        GRDIS: 'ST1TS0T1', # Discontinuance
        GRGLT: 'ST1TS0T2', # Guilty plea
        GRTRL: 'ST1TS0T4', # Trial
        GRRTR: 'ST1TS0TA', # Retrial
        GRRAK: 'ST1TS0T3', # Cracked trial
        GRCBR: 'ST1TS0T9', # Cracked before retrial
      }.freeze

      context 'bill mappings' do
        BILL_TYPE_MAPPINGS.each do |unique_code, bill_types|
          BILL_SCENARIO_MAPPINGS.each do |fee_type_code, scenario|
            context "when a misc fee of type #{unique_code} is attached to a claim with case of type #{fee_type_code}" do
              subject(:instance) { described_class.new(fee) }
              let(:claim) { instance_double('claim', case_type: case_type) }
              let(:case_type) { instance_double('case_type', fee_type_code: fee_type_code) }
              let(:fee_type) { instance_double('fee_type', unique_code: unique_code) }

              before do
                allow(fee).to receive(:claim).and_return claim
                allow(fee).to receive(:fee_type).and_return fee_type
              end

              describe '#bill_type' do
                it "returns #{bill_types.first}" do
                  expect(instance.bill_type).to eql bill_types.first
                end
              end

              describe '#bill_subtype' do
                it "returns #{bill_types.second}" do
                  expect(instance.bill_subtype).to eql bill_types.second
                end
              end

              describe '#bill_scenario' do
                it "returns #{scenario}" do
                  expect(instance.bill_scenario).to eql scenario
                end
              end
            end
          end
        end
      end
    end
  end
end
