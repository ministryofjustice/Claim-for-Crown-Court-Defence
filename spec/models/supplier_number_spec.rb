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

  it { should validate_uniqueness_of(:supplier_number) }

  subject { build(:supplier_number) }

  context 'validates supplier number format' do
    let(:format_error) { ['invalid format or lowercase'] }

    it 'fails for incorrect format' do
      allow(subject).to receive(:supplier_number).and_return('ABC123')
      expect(subject).not_to be_valid
      expect(subject.errors[:supplier_number]).to eq(format_error)
    end

    it 'fails for correct format but lowercase' do
      allow(subject).to receive(:supplier_number).and_return('1b222z')
      expect(subject).not_to be_valid
      expect(subject.errors[:supplier_number]).to eq(format_error)
    end

    it 'pass for correct format' do
      allow(subject).to receive(:supplier_number).and_return('1B222Z')
      expect(subject).to be_valid
    end
  end
end
