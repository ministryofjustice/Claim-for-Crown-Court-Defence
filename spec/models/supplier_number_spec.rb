# == Schema Information
#
# Table name: supplier_numbers
#
#  id              :integer          not null, primary key
#  provider_id     :integer
#  supplier_number :string
#

require 'rails_helper'

RSpec.describe SupplierNumber, type: :model do

  subject(:supplier) { build(:supplier_number) }

  context 'uniqueness' do
    it 'should fail if two records with the same suppplier number are created' do
      create :supplier_number, supplier_number: '9X999X'
      expect {
        create :supplier_number, supplier_number: '9X999X'
      }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Supplier number has already been taken'
    end

    it 'should fail if the supplier number after upcasing is the same as an existing record' do
      create :supplier_number, supplier_number: '9X999X'
      expect {
        create :supplier_number, supplier_number: '9x999x'
      }.to raise_error ActiveRecord::RecordInvalid, 'Validation failed: Supplier number has already been taken'
    end
  end

  context 'postcode validation' do
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

    it 'is invalid if postcode is filled and has the wrong format' do
      supplier.postcode = 'not-a-valid-postcode'
      expect(supplier).not_to be_valid
      expect(supplier.errors[:postcode]).to include('is invalid')
    end
  end

  context 'validates supplier number format' do
    let(:format_error) { ['invalid format'] }

    it 'fails for incorrect format' do
      allow(subject).to receive(:supplier_number).and_return('ABC123')
      expect(subject).not_to be_valid
      expect(subject.errors[:supplier_number]).to eq(format_error)
    end

    it 'succeeds for correct format but lowercase' do
      allow(subject).to receive(:supplier_number).and_return('1b222z')
      expect(subject).to be_valid
      expect(subject.supplier_number).to eq '1B222Z'
    end

    it 'pass for correct format' do
      allow(subject).to receive(:supplier_number).and_return('1B222Z')
      expect(subject).to be_valid
    end
  end

  describe '#has_non_archived_claims?' do
    let(:relation) { double(ActiveRecord::Relation) }
    subject { described_class.new(supplier_number: '6X666X') }

    before do
      expect(Claim::BaseClaim).to receive(:non_archived_pending_delete).and_return(relation)
      expect(relation).to receive(:where).with(supplier_number: '6X666X').and_return(claims)
    end

    context 'when there are claims' do
      let(:claims) { [double('Claim')] }

      it 'returns true' do
        expect(subject.has_non_archived_claims?).to be true
      end
    end

    context 'when there are no claims' do
      let(:claims) { [] }

      it 'returns false' do
        expect(subject.has_non_archived_claims?).to be false
      end
    end
  end
end
