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

  it { should belong_to(:fee)     }
  it { should belong_to(:expense) }
  it { should validate_presence_of(:fee) }
  it { should validate_presence_of(:expense)}
  it { should validate_presence_of(:date) }

  describe "#belongs_to_fee_or_expense" do

    context "should conditionally validate presence of fee OR expense" do

      let(:fee)     { create(:fee) }
      let(:expense) { create(:expense) }
      let(:fee_dates)     { create(:date_attended, fee: fee) }
      let(:expense_dates) { create(:date_attended, fee: nil, expense: expense) }
      let(:fee_expense_dates) { create(:date_attended, fee: fee, expense: expense) }
      let(:no_association) { create(:date_attended, fee: nil, expense: nil) }

      it 'should not raise an error for a fee association' do
       expect{fee_dates}.to_not raise_error
      end
      it 'should not raise an error for an expense association' do
       expect{expense_dates}.to_not raise_error
      end
      it 'should raise an error for a fee AND expense association' do
       expect{fee_expense_dates}.to raise_error
      end
      it 'should raise an error for NO association' do
       expect{no_association}.to raise_error
      end
    end
  end

  describe '#to_s' do
    context 'when date_to present' do
      subject { create(:date_attended, date: Date.parse('1/1/2015'), date_to: Date.parse('5/1/2015')) }

      it 'formats the date and date_to' do
        expect(subject.to_s).to eq('01/01/2015 - 05/01/2015')
      end
    end

    context 'when only date present' do
      subject { create(:date_attended, date: Date.parse('1/1/2015'), date_to: nil) }

      it 'formats the date' do
        expect(subject.to_s).to eq('01/01/2015')
      end
    end
  end
end
