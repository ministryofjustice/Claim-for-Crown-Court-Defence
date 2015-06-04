# == Schema Information
#
# Table name: dates_attended
#
#  id         :integer          not null, primary key
#  date       :datetime
#  fee_id     :integer
#  created_at :datetime
#  updated_at :datetime
#  date_to    :datetime
#

require 'rails_helper'

RSpec.describe DateAttended, type: :model do
  it { should belong_to(:fee) }
  it { should validate_presence_of(:date) }

  describe '#to_s' do
    context 'when date_to present' do
      subject { create(:date_attended, date: Date.parse('1/1/2015'), date_to: Date.parse('5/1/2015')) }

      it 'formats the date and date_to' do
        expect(subject.to_s).to eq('01/01/15 - 05/01/15')
      end
    end

    context 'when only date present' do
      subject { create(:date_attended, date: Date.parse('1/1/2015')) }

      it 'formats the date' do
        expect(subject.to_s).to eq('01/01/15')
      end
    end
  end
end
