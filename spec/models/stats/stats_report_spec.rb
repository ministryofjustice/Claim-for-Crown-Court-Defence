require 'rails_helper'

RSpec.describe Stats::StatsReport do
  context 'management information reports' do
    before(:all) do
      @mi_old = create :stats_report, started_at: 10.days.ago
      @mi_complete = create :stats_report
      @mi_incomplete = create :stats_report, :incomplete
      @other_report = create :stats_report, :other_report
      @error_report = create :stats_report, :error
    end

    after(:all) do
      described_class.delete_all
    end

    describe '.most_recent_by_type' do
      let(:report_type) { 'provisional_assessment' }

      context 'when there is no reports for the specified type' do
        it { expect(described_class.most_recent_by_type('some_random_name')).to be_nil }
      end

      context 'when there is no completed reports for the specified type' do
        before do
          create(:stats_report, :incomplete, report_name: report_type)
          create(:stats_report, :error, report_name: report_type)
        end

        it { expect(described_class.most_recent_by_type(report_type)).to be_nil }
      end

      context 'when there is some completed reports for the specified type' do
        let!(:in_progress_report) { create(:stats_report, :incomplete, report_name: report_type, started_at: 1.minute.ago) }
        let!(:most_recent_report) { create(:stats_report, report_name: report_type, started_at: 5.minutes.ago) }
        let!(:not_so_recent_report) { create(:stats_report, report_name: report_type, started_at: 3.months.ago) }

        it 'returns the most recent completed report' do
          expect(described_class.most_recent_by_type(report_type)).to eq(most_recent_report)
        end
      end
    end

    it 'returns all management information reports' do
      results = described_class.management_information
      expect(results.size).to eq 3
      expect(results).to include(@mi_complete)
      expect(results).to include(@mi_incomplete)
      expect(results).to include(@mi_old  )
    end

    it 'returns the latest completed management information report' do
      expect(described_class.most_recent_management_information).to eq @mi_complete
    end

    describe '.report_generation_in_progress?' do
      it 'returns true for management information' do
        expect(described_class.generation_in_progress?('management_information')).to be true
      end

      it 'returns false for other reports' do
        expect(described_class.generation_in_progress?('other_report')).to be false
      end
    end

    describe '#download_filename' do
      it 'generates a filename incorportating the report name and started at time' do
        report = build :stats_report, report_name: 'my_new_report', started_at: Time.zone.local(2016, 2, 3, 4, 55, 12)
        expect(report.download_filename).to eq 'my_new_report_2016_02_03_04_55_12.csv'
      end
    end

    describe '.record_start' do
      it 'creates and incomplete record' do
        frozen_time = Time.new(2015, 3, 16, 13, 36, 12)
        Timecop.freeze(frozen_time) do
          record = described_class.record_start('my_new_report')
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
          record = described_class.record_start('my_new_report')
        end

        Timecop.freeze(frozen_time + 2.minutes) do
          record.write_report('The contents of my new report')
        end

        report = described_class.completed.where(report_name: 'my_new_report').first
        expect(report.report).to eq 'The contents of my new report'
        expect(report.started_at).to eq frozen_time
        expect(report.completed_at).to eq frozen_time + 2.minutes
      end
    end
  end

  context 'housekeeping' do
    describe '.destroy_reports_older_than' do
      it 'destroys all reports for named report older than specified time' do
        _my_report_old = create :stats_report, started_at: 63.days.ago
        my_report_new = create :stats_report, started_at: 53.days.ago
        other_report_old = create :stats_report, :other_report, started_at: 63.days.ago
        other_report_new = create :stats_report, :other_report, started_at: 53.days.ago

        described_class.destroy_reports_older_than('management_information', 62.days.ago)
        expect(described_class.all).to match_array [my_report_new, other_report_old, other_report_new]
      end
    end

    describe '.destroy_unfinished_reports_older_than' do
      it 'destroys incomplete reports started before the timestamp' do
        _my_report_old = create :stats_report, :incomplete, started_at: 121.minutes.ago
        my_report_new = create :stats_report, :incomplete, started_at: 119.minutes.ago
        other_report_old = create :stats_report, :other_report, :incomplete, started_at: 121.minutes.ago
        other_report_new = create :stats_report, :other_report, :incomplete, started_at: 119.minutes.ago

        described_class.destroy_unfinished_reports_older_than('management_information', 2.hours.ago)
        expect(described_class.all).to match_array [my_report_new, other_report_old, other_report_new]
      end
    end
  end
end
