require 'rails_helper'

describe CaseWorkers::Admin::AllocationsHelper do
  describe '#owner_column_header' do
    it 'should return advocate for agfs filter or by default' do
      expect(owner_column_header).to eql 'Advocate'
      allow(params).to receive(:[]).with(:scheme).and_return('agfs')
      expect(owner_column_header).to eql 'Advocate'
    end

    it 'should return litigator for lgfs filter' do
      allow(params).to receive(:[]).with(:scheme).and_return('lgfs')
      expect(owner_column_header).to eql 'Litigator'
    end
  end
end
