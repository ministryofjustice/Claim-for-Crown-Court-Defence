require 'rails_helper'

module Claim
  describe TransferBrainDataItemCollection do

    let(:collection)  { TransferBrainDataItemCollection.instance }

    describe '.new' do
      it 'should create a collection from the yaml file' do
        expect(collection.instance_variable_get(:@collection).size).to eq 34
      end
    end

    describe '#to_h' do
      it 'returns a merged hash' do
        expect(collection.to_h).to eq expected_hash
      end
    end

    describe '#data_item_for' do
      it 'returns the data item for a detail for a specific case conclusion id' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 20, case_conclusion_id: 10
        expected = {:visibility=>true, :validity=>true, :transfer_fee_full_name=>"Before trial transfer (new) - trial", :allocation_case_type=>"Grad"}
        expect(collection.data_item_for(detail)).to eq expected
      end

      it 'returns the data item for a detail where the data item has * for case conclusion in the hash' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: 20
        expected = {:visibility=>false, :validity=>true, :transfer_fee_full_name=>"Elected case - up to and including PCMH transfer (new)", :allocation_case_type=>"Fixed"}
        expect(collection.data_item_for(detail)).to eq expected
      end
    end

    describe '#transfer_fee_full_name' do
      it 'returns transfer fee full name for the matching detail with wildcase case conclusion id' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: 20
        expect(collection.transfer_fee_full_name(detail)).to eq 'Elected case - up to and including PCMH transfer (new)'
      end

      it 'returns transfer fee full name for matching detail records with a specific case conclusion id' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 50
        expect(collection.transfer_fee_full_name(detail)).to eq 'Up to and including PCMH transfer (new) - guilty plea'
      end

      it 'raises if given an invalid combination' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 20
        expect{ collection.transfer_fee_full_name(detail) }.to raise_error ArgumentError, 'Invalid combination of transfer detail fields'
      end
    end

    describe '#allocation_case_type' do
      it 'returns allocation case type for the matching detail with wildcase case conclusion id' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: 20
        expect(collection.allocation_case_type(detail)).to eq 'Fixed'
      end

      it 'returns allocation case type for matching detail records with a specific case conclusion id' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 50
        expect(collection.allocation_case_type(detail)).to eq 'Grad'
      end

      it 'raises if given an invalid combination' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 20
        expect{ collection.allocation_case_type(detail) }.to raise_error ArgumentError, 'Invalid combination of transfer detail fields'
      end
    end

    describe '#valid_detail?(detail)' do
      it 'returns true for details with a valid combination of fields' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 50
        expect(collection.detail_valid?(detail)).to be true
      end

      it 'returns false for details with an invalid combination of fields' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 70, case_conclusion_id: 50
        expect(collection.detail_valid?(detail)).to be true
      end

      it 'returns false if given an invalid combination' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 20
        expect(collection.detail_valid?(detail)).to be false
      end
    end




    def expected_hash
      {"new"=>
         {true=>
            {10=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"Elected case - up to and including PCMH transfer (new)", :allocation_case_type=>"Fixed"}},
             20=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"Elected case - before trial transfer (new)", :allocation_case_type=>"Fixed"}},
             30=>{"*"=>{:visibility=>false, :validity=>false, :transfer_fee_full_name=>nil, :allocation_case_type=>nil}},
             40=>{"*"=>{:visibility=>false, :validity=>false, :transfer_fee_full_name=>nil, :allocation_case_type=>nil}},
             50=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"Elected case - transfer before retrial (new)", :allocation_case_type=>"Fixed"}},
             60=>{"*"=>{:visibility=>false, :validity=>false, :transfer_fee_full_name=>nil, :allocation_case_type=>nil}},
             70=>{"*"=>{:visibility=>false, :validity=>false, :transfer_fee_full_name=>nil, :allocation_case_type=>nil}}},
          false=>
            {10=>
               {30=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"Up to and including PCMH transfer (new) - cracked", :allocation_case_type=>"Grad"},
                50=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"Up to and including PCMH transfer (new) - guilty plea", :allocation_case_type=>"Grad"},
                10=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"Up to and including PCMH transfer (new) - trial ", :allocation_case_type=>"Grad"}},
             20=>
               {30=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"Before trial transfer (new) - cracked", :allocation_case_type=>"Grad"},
                10=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"Before trial transfer (new) - trial", :allocation_case_type=>"Grad"}},
             30=>
               {20=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"During trial transfer (new) - retrial", :allocation_case_type=>"Grad"},
                10=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"During trial transfer (new) - trial", :allocation_case_type=>"Grad"}},
             40=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"Transfer after trial and before sentence hearing (new)", :allocation_case_type=>"Grad"}},
             50=>
               {40=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"transfer before retrial (new) cracked retrial", :allocation_case_type=>"Grad"},
                20=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"transfer before retrial (new) retrial", :allocation_case_type=>"Grad"}},
             60=>{20=>{:visibility=>true, :validity=>true, :transfer_fee_full_name=>"transfer during retrial (new) retrial", :allocation_case_type=>"Grad"}},
             70=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"transfer after retrial and before sentence hearing (new)", :allocation_case_type=>"Grad"}}}},
       "original"=>
         {true=>
            {10=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"elected case - up to and including PCMH transfer (org)", :allocation_case_type=>"Fixed"}},
             20=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"elected case - before trial transfer (org)", :allocation_case_type=>"Fixed"}},
             30=>{"*"=>{:visibility=>false, :validity=>false, :transfer_fee_full_name=>nil, :allocation_case_type=>nil}},
             40=>{"*"=>{:visibility=>false, :validity=>false, :transfer_fee_full_name=>nil, :allocation_case_type=>nil}},
             50=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"elected case - transfer before retrial (org)", :allocation_case_type=>"Fixed"}},
             60=>{"*"=>{:visibility=>false, :validity=>false, :transfer_fee_full_name=>nil, :allocation_case_type=>nil}},
             70=>{"*"=>{:visibility=>false, :validity=>false, :transfer_fee_full_name=>nil, :allocation_case_type=>nil}}},
          false=>
            {10=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"up to and including PCMH transfer (org)", :allocation_case_type=>"Grad"}},
             20=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"before trial transfer (org)", :allocation_case_type=>"Grad"}},
             30=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"during trial transfer (org) - trial", :allocation_case_type=>"Grad"}},
             40=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"transfer after trial and before sentence hearing (org)", :allocation_case_type=>"Grad"}},
             50=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"transfer before retrial (org) - retrial", :allocation_case_type=>"Grad"}},
             60=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"transfer during retrial (org) retrial", :allocation_case_type=>"Grad"}},
             70=>{"*"=>{:visibility=>false, :validity=>true, :transfer_fee_full_name=>"transfer after retrial and before sentence hearing (org)", :allocation_case_type=>"Grad"}}
            }
         }
      }
    end

  end
end
