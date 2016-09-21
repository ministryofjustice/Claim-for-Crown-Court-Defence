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

  subject { build(:supplier_number) }

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

  context 'validates supplier number format' do
    let(:format_error) { ['invalid format or lowercase'] }

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
end
