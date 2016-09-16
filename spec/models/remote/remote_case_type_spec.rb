require 'rails_helper'

module Remotes
  describe RemoteCaseType do

    context 'caching' do
      it 'fetches data from the api just onece on start up' do
        expect(RestClient).to receive(:get).with('http://localhost:3001/api/case_types?api_key=753822a6-dd7a-43bc-a48a-e8b3698504d5').and_return(response).at_most(:once)
        RemoteCaseType.agfs
        RemoteCaseType.lgfs
        RemoteCaseType.interims
        RemoteCaseType.all
      end
    end


    context 'class_methods' do

      before(:each) do
        allow(RestClient).to receive(:get).with('http://localhost:3001/api/case_types?api_key=753822a6-dd7a-43bc-a48a-e8b3698504d5').and_return(response)
      end

      describe '.all' do
        it 'returns an array of open structs of all case types' do
          case_types = RemoteCaseType.all
          expect(case_types.map(&:class).uniq).to eq([OpenStruct])
          expect(case_types.map(&:id)).to eq([ 1, 9, 13, 11, 12 ])
        end
      end

      describe '.agfs' do
        it 'returns an array of open structs with roles agfs' do
          expect(RemoteCaseType.agfs.map(&:id)).to eq([ 1, 9, 11, 12 ])
        end
      end

      describe '.lgfs' do
        it 'returns an array of open structs with roles agfs' do
          expect(RemoteCaseType.lgfs.map(&:id)).to eq([ 1, 9, 13, 11, 12 ])
        end
      end

      describe '.interims' do
        it 'returns an array of open structs with roles agfs' do
          expect(RemoteCaseType.interims.map(&:id)).to eq([ 11, 12 ])
        end
      end

      describe '.find' do
        it 'returns the ostruct with the specified id' do
          ct = RemoteCaseType.find(9)
          expect(ct.id).to eq 9
          expect(ct.name).to eq("Elected cases not proceeded**")
          expect(ct.is_fixed_fee).to be true
          expect(ct.requires_cracked_dates).to be false
          expect(ct.requires_trial_dates).to be false
          expect(ct.allow_pcmh_fee_type).to be false
          expect(ct.requires_maat_reference).to be true
          expect(ct.requires_retrial_dates).to be false
          expect(ct.roles).to eq(["agfs", "lgfs"])
        end
      end
    end



    def response
      [
        {"id"=>1,
        "name"=>"Appeal against conviction",
        "is_fixed_fee"=>true,
        "requires_cracked_dates"=>false,
        "requires_trial_dates"=>false,
        "allow_pcmh_fee_type"=>false,
        "requires_maat_reference"=>true,
        "requires_retrial_dates"=>false,
        "roles"=>["agfs", "lgfs"],
        "fee_type_code"=>"ACV"},
       {"id"=>9,
        "name"=>"Elected cases not proceeded",
        "is_fixed_fee"=>true,
        "requires_cracked_dates"=>false,
        "requires_trial_dates"=>false,
        "allow_pcmh_fee_type"=>false,
        "requires_maat_reference"=>true,
        "requires_retrial_dates"=>false,
        "roles"=>["agfs", "lgfs"],
        "fee_type_code"=>"ENP"},
       {"id"=>13,
        "name"=>"Hearing subsequent to sentence",
        "is_fixed_fee"=>true,
        "requires_cracked_dates"=>false,
        "requires_trial_dates"=>false,
        "allow_pcmh_fee_type"=>false,
        "requires_maat_reference"=>true,
        "requires_retrial_dates"=>false,
        "roles"=>["lgfs"],
        "fee_type_code"=>"XH2S"},
       {"id"=>11,
        "name"=>"Retrial",
        "is_fixed_fee"=>false,
        "requires_cracked_dates"=>false,
        "requires_trial_dates"=>true,
        "allow_pcmh_fee_type"=>true,
        "requires_maat_reference"=>true,
        "requires_retrial_dates"=>true,
        "roles"=>["agfs", "lgfs", "interim"],
        "fee_type_code"=>"GRTR"},
       {"id"=>12,
        "name"=>"Trial",
        "is_fixed_fee"=>false,
        "requires_cracked_dates"=>false,
        "requires_trial_dates"=>true,
        "allow_pcmh_fee_type"=>true,
        "requires_maat_reference"=>true,
        "requires_retrial_dates"=>false,
        "roles"=>["agfs", "lgfs", "interim"],
        "fee_type_code"=>"GTRL"}
      ].to_json
    end
  end
end
