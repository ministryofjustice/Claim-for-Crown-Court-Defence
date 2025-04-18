# == Schema Information
#
# Table name: dates_attended
#
#  id                 :integer          not null, primary key
#  date               :date
#  created_at         :datetime
#  updated_at         :datetime
#  date_to            :date
#  uuid               :uuid
#  attended_item_id   :integer
#  attended_item_type :string
#

require 'rails_helper'

RSpec.describe DateAttended do
  let(:date) { Time.zone.today - 1.year }

  it { should belong_to(:attended_item) }

  describe '#to_s' do
    context 'when date_to present' do
      subject { create(:date_attended, date: Date.parse("1/1/#{date.year}"), date_to: Date.parse("5/1/#{date.year}")) }

      it 'formats the date and date_to' do
        expect(subject.to_s).to eq("01/01/#{date.year} - 05/01/#{date.year}")
      end
    end

    context 'when only date present' do
      subject { create(:date_attended, date: Date.parse("1/1/#{date.year}"), date_to: nil) }

      it 'formats the date' do
        expect(subject.to_s).to eq("01/01/#{date.year}")
      end
    end
  end
end
