RSpec.describe SupplierNumber, type: :model do
  subject(:supplier) { build(:supplier_number) }

  context 'when validating uniqueness' do
    before { create(:supplier_number, supplier_number: '9X999X') }

    specify do
      expect {
        create :supplier_number, supplier_number: '9X999X'
      }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Supplier number has already been taken'
    end

    specify do
      expect {
        create :supplier_number, supplier_number: '9x999x'
      }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Supplier number has already been taken'
    end
  end

  context 'when validating postcode' do
    it 'is valid if postcode is nil' do
      supplier.postcode = nil
      expect(supplier).to be_valid
    end

    it 'is valid if postcode is blank' do
      supplier.postcode = ''
      expect(supplier).to be_valid
    end

    it 'is valid if postcode is filled and has the right format' do
      supplier.postcode = 'SW1H 9AJ'
      expect(supplier).to be_valid
    end

    context 'with wrong format' do
      before do
        supplier.postcode = 'not-a-valid-postcode'
        supplier.validate
      end

      it { expect(supplier).to be_invalid }
      it { expect(supplier.errors[:postcode]).to include('Enter a valid postcode') }
    end
  end

  context 'when validating supplier number' do
    let(:format_error) { ['Enter a valid LGFS supplier number'] }

    before do
      allow(supplier).to receive(:supplier_number).and_return(supplier_number)
      supplier.validate
    end

    context 'with invalid format' do
      let(:supplier_number) { 'ABC123' }

      it { expect(supplier.errors[:supplier_number]).to eq(format_error) }
    end

    context 'with valid lowercase format' do
      let(:supplier_number) { '1b222z' }

      it { expect(supplier).to be_valid }
      it { expect(supplier.supplier_number).to eq '1B222Z' }
    end

    context 'with valid format' do
      let(:supplier_number) { '1B222Z' }

      it { expect(supplier).to be_valid }
    end
  end

  describe '#has_non_archived_claims?' do
    subject { described_class.new(supplier_number: '6X666X').has_non_archived_claims? }

    let(:relation) { double(ActiveRecord::Relation) }

    before do
      expect(Claim::BaseClaim).to receive(:non_archived_pending_delete).and_return(relation)
      expect(relation).to receive(:where).with(supplier_number: '6X666X').and_return(claims)
    end

    context 'when there are claims' do
      let(:claims) { [double('Claim')] }

      it { is_expected.to be_truthy }
    end

    context 'when there are no claims' do
      let(:claims) { [] }

      it { is_expected.to be_falsey }
    end
  end
end
