require 'rails_helper'

RSpec.describe Reports::SubmittedClaims do
  describe '#call' do
    subject(:response) { described_class.call }

    let(:start_of_final_week) { Time.zone.parse('21 June 2021') }

    before { travel_to(start_of_final_week + 9.days) }

    it 'counts the correct number of submitted claims for last week' do
      create(:claim, original_submission_date: Time.zone.parse('28 June 2021 01:01'))
      create(:claim, original_submission_date: Time.zone.parse('27 June 2021 15:31'))
      create(:claim, original_submission_date: Time.zone.parse('21 June 2021 01:01'))
      create(:claim, original_submission_date: Time.zone.parse('19 June 2021 12:00'))

      expect(response.last).to contain_exactly('21/06/2021', 2)
    end

    it 'has results for the correct 12 weeks' do
      last_twelve_mondays = Array.new(12) { |i| start_of_final_week - i.weeks }
      last_twelve_mondays.each { |date| create(:claim, original_submission_date: date + 12.hours) }
      create(:claim, original_submission_date: Time.zone.parse('28 June 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('1 April 2021 12:00'))

      expect(response.map(&:first)).to match_array(last_twelve_mondays.map { |date| date.strftime('%d/%m/%Y') })
    end
  end
end
