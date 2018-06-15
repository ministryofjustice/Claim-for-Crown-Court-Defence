require 'rails_helper'

RSpec.describe SupplierNumberCollectionPresenter do
  let(:supplier_numbers) { build_list(:supplier_number, 3) }

  subject(:presenter) { described_class.new(supplier_numbers, view) }

  describe '#each' do
    it 'iterates over presented supplier numbers' do
      expect(presenter).to all(be_kind_of(SupplierNumberPresenter))
    end
  end
end
