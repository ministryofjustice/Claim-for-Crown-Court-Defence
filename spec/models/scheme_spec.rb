# == Schema Information
#
# Table name: schemes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
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
end
