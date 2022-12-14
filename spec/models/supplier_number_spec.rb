RSpec.describe SupplierNumber do
  subject(:supplier) { build(:supplier_number) }

  it { is_expected.to belong_to(:provider) }

  context 'when validating postcode' do
    let(:invalid_postcode_message) { 'Enter a valid postcode' }

    it { is_expected.to allow_value(nil).for(:postcode) }
    it { is_expected.to allow_value('').for(:postcode) }
    it { is_expected.to allow_value('SW1H 9AJ').for(:postcode) }
    it { is_expected.not_to allow_value('123').for(:postcode).with_message(invalid_postcode_message) }
    it { is_expected.not_to allow_value('SW1H').for(:postcode).with_message(invalid_postcode_message) }
  end

  context 'when validating supplier number' do
    let(:invalid_supplier_message) { 'Enter a valid LGFS supplier number' }
    let(:blank_supplier_message) { 'Enter an LGFS supplier number' }

    it { is_expected.to allow_value('9A999A').for(:supplier_number) }
    it { is_expected.not_to allow_value(nil).for(:supplier_number).with_message(blank_supplier_message) }
    it { is_expected.not_to allow_value('').for(:supplier_number).with_message(blank_supplier_message) }

    it { is_expected.not_to allow_value('9AA99A').for(:supplier_number).with_message(invalid_supplier_message) }
    it { is_expected.not_to allow_value('AA999A').for(:supplier_number).with_message(invalid_supplier_message) }
    it { is_expected.not_to allow_value('9A9999').for(:supplier_number).with_message(invalid_supplier_message) }
    it { is_expected.not_to allow_value('9A9A9A').for(:supplier_number).with_message(invalid_supplier_message) }
    it { is_expected.not_to allow_value('9A99AA').for(:supplier_number).with_message(invalid_supplier_message) }

    it {
      is_expected.to validate_uniqueness_of(:supplier_number)
        .case_insensitive
        .with_message('Enter supplier number that has not already been taken')
    }
  end

  it 'upcases supplier number before validation' do
    supplier.supplier_number = '1b222z'
    supplier.validate
    expect(supplier.supplier_number).to eq '1B222Z'
  end

  describe '#to_s' do
    subject { described_class.new(supplier_number: '6X666X').to_s }

    it { is_expected.to eq('6X666X') }
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
