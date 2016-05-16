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
        expected = { :validity=>true, :transfer_fee_full_name=>"before trial transfer (new) - trial", :allocation_type=>"Grad"}
        expect(collection.data_item_for(detail)).to eq expected
      end

      it 'returns the data item for a detail where the data item has * for case conclusion in the hash' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: 20
        expected = { :validity=>true, :transfer_fee_full_name=>"elected case - up to and including PCMH transfer (new)", :allocation_type=>"Fixed"}
        expect(collection.data_item_for(detail)).to eq expected
      end
    end

    describe '#transfer_fee_full_name' do
      it 'returns transfer fee full name for the matching detail with wildcard case conclusion id' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: 20
        expect(collection.transfer_fee_full_name(detail)).to eq 'elected case - up to and including PCMH transfer (new)'
      end

      it 'returns transfer fee full name for matching detail records with a specific case conclusion id' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 50
        expect(collection.transfer_fee_full_name(detail)).to eq 'up to and including PCMH transfer (new) - guilty plea'
      end

      it 'raises error if given an invalid combination' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 20
        expect{ collection.transfer_fee_full_name(detail) }.to raise_error InvalidTransferCombinationError, 'Invalid combination of transfer detail fields'
      end
    end

    describe '#allocation_type' do
      it 'returns allocation case type for the matching detail with wildcard case conclusion id' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: true, transfer_stage_id: 10, case_conclusion_id: 20
        expect(collection.allocation_type(detail)).to eq 'Fixed'
      end

      it 'returns allocation case type for matching detail records with a specific case conclusion id' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 50
        expect(collection.allocation_type(detail)).to eq 'Grad'
      end

      it 'raises error if given an invalid combination' do
        detail = build :transfer_detail, litigator_type: 'new', elected_case: false, transfer_stage_id: 10, case_conclusion_id: 20
        expect{ collection.allocation_type(detail) }.to raise_error InvalidTransferCombinationError, 'Invalid combination of transfer detail fields'
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

    describe '#valid_transfer_stage_ids' do
      context 'new litigator type with elected case' do
        it 'returns a list of valid transfer_stage_ids' do
          expect(TransferBrainDataItemCollection.instance.valid_transfer_stage_ids('new', true)).to eq([ 10, 20, 50 ])
        end
      end

      context 'new litigator type and non elected case' do
        it 'returns a list of valid transfer_stage_ids' do
          expect(TransferBrainDataItemCollection.instance.valid_transfer_stage_ids('new', false)).to eq([10, 20, 30, 40, 50, 60, 70])
        end
      end
    end

    describe '#valid_case_conclusion_ids' do
      context 'new litigator type with elected case and transfer stage id of 20' do
        it 'returns a full set of conclusiont ids' do
          expect(TransferBrainDataItemCollection.instance.valid_case_conclusion_ids('new', true, 20)).to eq([ 10, 20, 30, 40, 50 ])
        end
      end

      context 'new litigator type with elected case and transfer stage id of 20' do
        it 'returns a limited set of conclusion ids' do
          expect(TransferBrainDataItemCollection.instance.valid_case_conclusion_ids('new', false, 20)).to eq( [ 10, 30 ])
        end
      end
    end

    #
    # Hash elements:
    #
    # litigator type (new, original)
    #   - elected case (boolean)
    #     - transfer stage id (int)
    #       - case conclusion id (int) - * means any
    #         - attributes:
    #              - REMOVED: (see transfer brains): visibility: whether combination should display the "how did case conclude?" - use in views
    #              - validity: whether combination is valid - use in validators
    #              - transfer fee full name: the description to display to Case workers (only) on the claim details page (show action)
    #              - allocation type: what allocation filter "queue" this combination should fall into - use in scopes for allocation filters
    #
    def expected_hash
      {"new"=>
         {true=>
            {10=>{"*"=>{ :validity=>true,   :transfer_fee_full_name=>"elected case - up to and including PCMH transfer (new)", :allocation_type=>"Fixed"}},
             20=>{"*"=>{ :validity=>true,   :transfer_fee_full_name=>"elected case - before trial transfer (new)", :allocation_type=>"Fixed"}},
             30=>{"*"=>{ :validity=>false,  :transfer_fee_full_name=>nil, :allocation_type=>nil}},
             40=>{"*"=>{ :validity=>false,  :transfer_fee_full_name=>nil, :allocation_type=>nil}},
             50=>{"*"=>{ :validity=>true,   :transfer_fee_full_name=>"elected case - transfer before retrial (new)", :allocation_type=>"Fixed"}},
             60=>{"*"=>{ :validity=>false,  :transfer_fee_full_name=>nil, :allocation_type=>nil}},
             70=>{"*"=>{ :validity=>false,  :transfer_fee_full_name=>nil, :allocation_type=>nil}}},
          false=>
            {10=>
               {30=>{ :validity=>true, :transfer_fee_full_name=>"up to and including PCMH transfer (new) - cracked", :allocation_type=>"Grad"},
                50=>{ :validity=>true, :transfer_fee_full_name=>"up to and including PCMH transfer (new) - guilty plea", :allocation_type=>"Grad"},
                10=>{ :validity=>true, :transfer_fee_full_name=>"up to and including PCMH transfer (new) - trial ", :allocation_type=>"Grad"}},
             20=>
               {30=>{ :validity=>true, :transfer_fee_full_name=>"before trial transfer (new) - cracked", :allocation_type=>"Grad"},
                10=>{ :validity=>true, :transfer_fee_full_name=>"before trial transfer (new) - trial", :allocation_type=>"Grad"}},
             30=>
               {20=>{ :validity=>true, :transfer_fee_full_name=>"during trial transfer (new) - retrial", :allocation_type=>"Grad"},
                10=>{ :validity=>true, :transfer_fee_full_name=>"during trial transfer (new) - trial", :allocation_type=>"Grad"}},
             40=>{
                "*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer after trial and before sentence hearing (new)", :allocation_type=>"Grad"}},
             50=>
               {40=>{ :validity=>true, :transfer_fee_full_name=>"transfer before retrial (new) - cracked retrial", :allocation_type=>"Grad"},
                20=>{ :validity=>true, :transfer_fee_full_name=>"transfer before retrial (new) - retrial", :allocation_type=>"Grad"}},
             60=>{
                20=>{ :validity=>true, :transfer_fee_full_name=>"transfer during retrial (new) - retrial", :allocation_type=>"Grad"}},
             70=>{
                "*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer after retrial and before sentence hearing (new)", :allocation_type=>"Grad"}}}},
       "original"=>
         {true=>
            {10=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"elected case - up to and including PCMH transfer (org)", :allocation_type=>"Fixed"}},
             20=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"elected case - before trial transfer (org)", :allocation_type=>"Fixed"}},
             30=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil}},
             40=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil}},
             50=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"elected case - transfer before retrial (org)", :allocation_type=>"Fixed"}},
             60=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil}},
             70=>{"*"=>{ :validity=>false, :transfer_fee_full_name=>nil, :allocation_type=>nil}}},
          false=>
            {10=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"up to and including PCMH transfer (org)", :allocation_type=>"Grad"}},
             20=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"before trial transfer (org)", :allocation_type=>"Grad"}},
             30=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"during trial transfer (org) - trial", :allocation_type=>"Grad"}},
             40=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer after trial and before sentence hearing (org)", :allocation_type=>"Grad"}},
             50=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer before retrial (org) - retrial", :allocation_type=>"Grad"}},
             60=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer during retrial (org) - retrial", :allocation_type=>"Grad"}},
             70=>{"*"=>{ :validity=>true, :transfer_fee_full_name=>"transfer after retrial and before sentence hearing (org)", :allocation_type=>"Grad"}}
            }
         }
      }
    end

  end
end
