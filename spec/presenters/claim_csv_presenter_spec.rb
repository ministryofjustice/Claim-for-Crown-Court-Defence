require 'rails_helper'

RSpec.describe ClaimCsvPresenter do

  let(:claim)               { create(:allocated_claim) }
  let(:subject)             { ClaimCsvPresenter.new(claim, view) }

  context '#present! generates csv that contains' do

    it 'case_number' do
      subject.present! do |claim_journeys|
        expect(claim_journeys.first).to include(claim.case_number)
      end
    end

    it 'account number' do
      
    end

    it 'organistion/provider_name' do
      
    end

    it 'date last submitted' do
      
    end

    it 'case_type' do
      
    end

    it 'total (ex VAT)' do
      
    end

    it 'current state' do
      
    end

    it 'allocation date' do      
      
    end

    it 'allocation type (as per allocation tool filters)' do
      
    end

    it 'date of last assessment' do
      
    end

  end

end
