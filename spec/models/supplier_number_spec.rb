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
  it { should validate_presence_of(:supplier_number) }
  it { should validate_uniqueness_of(:supplier_number) }

  subject { build(:supplier_number) }

  context 'validates supplier number format' do
    it 'fails for incorrect format' do
      allow(subject).to receive(:supplier_number).and_return('abc123')
      expect(subject).not_to be_valid
    end

    it 'pass for correct format' do
      allow(subject).to receive(:supplier_number).and_return('1B222Z')
      expect(subject).to be_valid
    end
  end
end
