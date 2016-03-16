# == Schema Information
#
# Table name: stats_reports
#
#  id           :integer          not null, primary key
#  report_name  :string
#  report       :string
#  status       :string
#  started_at   :datetime
#  completed_at :datetime
#

require 'rails_helper'

module Stats

  describe StatsReport do

    before(:all) do
      @mi_old = create :stats_report, started_at: 10.days.ago
      @mi_complete = create :stats_report
      @mi_incomplete = create :stats_report, :incomplete
      @other_report = create :stats_report, :other_report
      @error_report = create :stats_report, :error
    end

    after(:all) do
      StatsReport.delete_all
    end

    it 'returns all management information reports' do
      results = StatsReport.management_information
      expect(results.size).to eq 3
      expect(results).to include(@mi_complete)
      expect(results).to include(@mi_incomplete)
      expect(results).to include(@mi_old  )
    end
 
    it 'returns the latest completed management information report' do
      expect(StatsReport.most_recent_management_information).to eq @mi_complete
    end

    describe '.report_generation_in_progress?' do
      it 'returns true for management information' do
        expect(StatsReport.generation_in_progress?('management_information')).to be true
      end

      it 'returns false for other reports' do
        expect(StatsReport.generation_in_progress?('other_report')).to be false
      end
    end

    describe '#download_filename' do
      it 'generates a filename incorportating the report name and started at time' do\
        report = build :stats_report, report_name: 'my_new_report', started_at: Time.new(2016, 2, 3, 4, 55, 12)
        expect(report.download_filename).to eq 'my_new_report_2016_02_03_04_55_12.csv'
      end
    end

    describe '.record_start' do
      it 'creates and incomplete record' do
        frozen_time = Time.new(2015, 3, 16, 13, 36, 12)
        Timecop.freeze(frozen_time) do
          record = StatsReport.record_start('my_new_report')
          expect(record.report_name).to eq 'my_new_report'
          expect(record.started_at).to eq frozen_time
          expect(record.completed_at).to be_nil
          expect(record.report).to be_nil
        end
      end
    end

    describe '#write_report' do
      it 'updates with report contents and completed_at time' do
        frozen_time = Time.new(2015, 3, 16, 13, 36, 12)
        record = nil
        Timecop.freeze(frozen_time) do
          record = StatsReport.record_start('my_new_report')
        end

        Timecop.freeze(frozen_time + 2.minutes) do
          record.write_report('The contents of my new report')
        end

        report = StatsReport.completed.where(report_name: 'my_new_report').first
        expect(report.report).to eq 'The contents of my new report'    
        expect(report.started_at).to eq frozen_time
        expect(report.completed_at).to eq frozen_time + 2.minutes
      end
    end
  end
end














