require 'rails_helper'

RSpec.shared_context 'add active storage record assets for stats reports' do
  before do
    ActiveStorage::Attachment.connection.execute(<<~SQL)
      INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
        VALUES('test_key', 'testfile_csv', 100, '{}', 100, 'abc==', NOW())
    SQL
    ActiveStorage::Attachment.connection.execute(<<~SQL)
      INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
        VALUES('document', 'Stats::StatsReport', #{report.id}, LASTVAL(), NOW())
    SQL
    allow(ActiveStorage::Blob).to receive(:service).and_return(service)
  end
end

RSpec.describe Stats::StatsReport do
  context 'management information reports' do
    before(:all) do
      @mi_old = create(:stats_report, started_at: 10.days.ago)
      @mi_complete = create(:stats_report)
      @mi_incomplete = create(:stats_report, :incomplete)
      @other_report = create(:stats_report, :other_report)
      @error_report = create(:stats_report, :error)
    end

    after(:all) do
      described_class.delete_all
    end

    describe '.most_recent_by_type' do
      let(:report_type) { :provisional_assessment }

      context 'when there is no reports for the specified type' do
        it { expect(described_class.most_recent_by_type(:some_random_name)).to be_nil }
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
      expect(results).to include(@mi_old)
    end

    it 'returns the latest completed management information report' do
      expect(described_class.most_recent_management_information).to eq @mi_complete
    end

    describe '.report_generation_in_progress?' do
      it 'returns true for management information' do
        expect(described_class.generation_in_progress?(:management_information)).to be true
      end

      it 'returns false for other reports' do
        expect(described_class.generation_in_progress?(:other_report)).to be false
      end
    end

    describe '#download_filename' do
      it 'generates a filename incorportating the report name and started at time' do
        report = build(:stats_report, report_name: :my_new_report, started_at: Time.zone.local(2016, 2, 3, 4, 55, 12))
        expect(report.download_filename).to eq 'my_new_report_20160203045512.csv'
      end
    end

    describe '.record_start' do
      it 'creates and incomplete record' do
        date = Time.zone.today - 1.year
        frozen_time = Time.zone.local(date.year, 3, 16, 13, 36, 12)
        travel_to(frozen_time) do
          record = described_class.record_start(:my_new_report)
          expect(record.report_name).to eq 'my_new_report'
          expect(record.started_at).to eq frozen_time
          expect(record.completed_at).to be_nil
        end
      end
    end

    describe '#write_report' do
      subject(:write_report) do
        report.tap do |r|
          travel_to(end_time) do
            r.write_report(Stats::Result.new(document_content, 'csv'))
          end
        end
      end

      let(:report) do
        travel_to(start_time) do
          described_class.record_start(:my_new_report)
        end
      end

      let(:document_content) { 'The contents of my report' }
      let(:start_time) { Time.zone.local(2021, 2, 24, 11, 24, 37) }
      let(:end_time) { Time.zone.local(2021, 2, 24, 11, 29, 12) }
      let(:checksum) { Digest::MD5.new.tap { |digest| digest << document_content }.base64digest }

      it 'copies the document to the document storage' do
        write_report
        file_name = ActiveStorage::Blob.service.path_for(report.document.blob.key)
        expect(File.read(file_name)).to eq document_content
      end

      it 'names the document based on the report type and timestamp' do
        write_report
        expect(report.document.filename).to eq "my_new_report_#{start_time.to_fs(:number)}.csv"
      end

      it 'does not change the started_at time' do
        expect { write_report }.not_to change(report, :started_at)
      end

      it 'updates the completed_at time' do
        expect { write_report }.to change(report, :completed_at).to(end_time)
      end

      it 'sets the report as current' do
        expect { write_report }
          .to change { described_class.completed.where(report_name: :my_new_report).first }
          .to report
      end
    end
  end

  describe '#destroy' do
    subject(:destroy_report) { report.destroy }

    let!(:report) { create(:stats_report, :with_document) }

    it { expect { destroy_report }.to change(ActiveStorage::Attachment, :count).by(-1) }
    it { expect { destroy_report }.to change(ActiveStorage::Blob, :count).by(-1) }
  end

  describe 'housekeeping' do
    describe '.destroy_reports_older_than' do
      it 'destroys all reports for named report older than specified time' do
        _my_report_old = create(:stats_report, started_at: 63.days.ago)
        my_report_new = create(:stats_report, started_at: 53.days.ago)
        other_report_old = create(:stats_report, :other_report, started_at: 63.days.ago)
        other_report_new = create(:stats_report, :other_report, started_at: 53.days.ago)

        described_class.destroy_reports_older_than(:management_information, 62.days.ago)
        expect(described_class.all).to contain_exactly(my_report_new, other_report_old, other_report_new)
      end
    end

    describe '.destroy_unfinished_reports_older_than' do
      it 'destroys incomplete reports started before the timestamp' do
        _my_report_old = create(:stats_report, :incomplete, started_at: 121.minutes.ago)
        my_report_new = create(:stats_report, :incomplete, started_at: 119.minutes.ago)
        other_report_old = create(:stats_report, :other_report, :incomplete, started_at: 121.minutes.ago)
        other_report_new = create(:stats_report, :other_report, :incomplete, started_at: 119.minutes.ago)

        described_class.destroy_unfinished_reports_older_than(:management_information, 2.hours.ago)
        expect(described_class.all).to contain_exactly(my_report_new, other_report_old, other_report_new)
      end
    end
  end
end
