# == Schema Information
#
# Table name: fee_categories
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  abbreviation :string(255)
#

require 'rails_helper'

RSpec.describe FeeCategory, type: :model do
  it { should have_many(:fee_types) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:abbreviation) }
  it { should validate_uniqueness_of(:abbreviation) }  

  context 'individual fee categories' do
    before(:each) do
      FactoryGirl.create :basic_fee_category
      FactoryGirl.create :fixed_fee_category
      FactoryGirl.create :misc_fee_category
    end

    describe '#basic' do
      it 'should return the basic fee category record' do 
        cat = FeeCategory.basic
        expect(cat.abbreviation).to eq 'BASIC'
      end
    end

    describe '#misc' do
      it 'should return the misc fee category record' do 
        cat = FeeCategory.misc
        expect(cat.abbreviation).to eq 'MISC'
      end
    end

    describe '#fixed' do
      it 'should return the fixed fee category record' do 
        cat = FeeCategory.fixed
        expect(cat.abbreviation).to eq 'FIXED'
      end
    end

    describe '#is_misc?' do
      it 'should return true for miscellaneous fees' do
        cat = FeeCategory.misc
        expect(cat.is_misc?).to be true
      end
      it 'should return false for other fees' do
        cat = FeeCategory.fixed
        expect(cat.is_misc?).to be false
      end
    end

    describe '#is_fixed?' do
      it 'should return true for fixed fees' do
        cat = FeeCategory.fixed
        expect(cat.is_fixed?).to be true
      end
      it 'should return true for other fees' do
        cat = FeeCategory.misc
        expect(cat.is_fixed?).to be false
      end
    end
  end
end
