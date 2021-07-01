require 'rails_helper'

RSpec.describe Stats::ReportGenerator::SubmittedClaims, type: :service do
  describe '.call' do
    subject(:result) { described_class.call }

    let(:rows) { CSV.parse(result.content) }

    before do
      travel_to(Date.parse('1 July 2021'))
      create(:claim, original_submission_date: Time.zone.parse('28 June 2021 01:01'))
      create(:claim, original_submission_date: Time.zone.parse('27 June 2021 15:31'))
      create(:claim, original_submission_date: Time.zone.parse('21 June 2021 01:01'))
      create(:claim, original_submission_date: Time.zone.parse('19 June 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('16 June 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('9 June 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('2 June 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('26 May 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('19 May 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('12 May 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('5 May 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('28 April 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('21 April 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('14 April 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('7 April 2021 12:00'))
      create(:claim, original_submission_date: Time.zone.parse('4 April 2021 12:00'))
      create_list(:claim, 5, original_submission_date: nil)
    end

    after { travel_back }

    it 'sets the correct headings' do
      expect(rows.first).to match_array(['Week starting', 'Submitted claims'])
    end

    it 'counts the number of submitted claims for last week' do
      expect(rows.last).to match_array(['21/06/2021', '2'])
    end

    it 'has results for the past 12 weeks' do
      t = Time.zone.parse('21 June 2021')
      last_twelve_mondays = Array.new(12) { |i| (t - i.weeks).strftime('%d/%m/%Y') }
      expect(rows.map(&:first)).to match_array(['Week starting', *last_twelve_mondays])
    end
  end
end
