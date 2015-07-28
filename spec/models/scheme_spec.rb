# == Schema Information
#
# Table name: schemes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  start_date :date
#  end_date   :date
#

require 'rails_helper'

RSpec.describe Scheme, type: :model do
  it { should have_many(:claims) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:start_date) }
  it { should validate_uniqueness_of(:start_date) }

  describe 'end date' do
    subject { build(:scheme) }

    it 'validates uniqueness of end date if not nil' do
      other_scheme = create(:scheme, end_date: Date.parse('10/07/2015'))
      subject.end_date = Date.parse('10/07/2015')
      expect(subject).to_not be_valid
    end

    it 'allows end date to be nil/blank' do
      subject.end_date = nil
      expect(subject).to be_valid
    end

    it 'does not validate uniqueness when end date is nil' do
      other_scheme = create(:scheme, end_date: nil)
      subject.end_date = nil
      expect(subject).to be_valid
    end
  end

  describe '.for_date' do
    before(:all) do
      @scheme_1 = FactoryGirl.create :scheme, start_date: Date.new(2010, 5, 1), end_date: Date.new(2012, 3, 31)
      @scheme_2 = FactoryGirl.create :scheme, start_date: Date.new(2012, 4, 1), end_date: Date.new(2012, 8, 13)
      @scheme_3 = FactoryGirl.create :scheme, start_date: Date.new(2012, 8, 14), end_date: nil
    end

    after(:all) do
      Scheme.delete_all
    end

    context 'before the first scheme started' do
      it 'should return nil' do
        expect(Scheme.for_date(Date.new(2000,1,1))).to be_nil
      end
    end

    context 'during scheme1 validity' do
      it 'should return scheme 1 for first day in scheme' do
        expect(Scheme.for_date(Date.new(2010, 5, 1))).to eq @scheme_1
      end
      it 'should return scheme 1 for middle of scheme' do
        expect(Scheme.for_date(Date.new(2010, 6, 1))).to eq @scheme_1
      end
      it 'should return scheme 1 for last day of scheme' do
        expect(Scheme.for_date(Date.new(2012, 3, 31))).to eq @scheme_1
      end
    end

    context 'during scheme 3 validity' do
      it 'should return scheme 3 for first day in scheme' do
        expect(Scheme.for_date(Date.new(2012, 8, 14))).to eq @scheme_3
      end

      it 'should return scheme 3 for any date after the start of scheme 3' do
        expect(Scheme.for_date(Date.new(2015, 8, 14))).to eq @scheme_3
      end
    end
  end
end
