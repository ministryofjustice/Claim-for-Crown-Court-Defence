require 'rails_helper'

RSpec.describe Stats::StatsReport do
  it_behaves_like 'an s3 bucket'

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
      expect(results).to include(@mi_old)
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
        expect(report.download_filename).to eq 'my_new_report_20160203045512.csv'
      end
    end

    describe '.record_start' do
      it 'creates and incomplete record' do
        frozen_time = Time.new(2015, 3, 16, 13, 36, 12)
        travel_to(frozen_time) do
          record = described_class.record_start('my_new_report')
          expect(record.report_name).to eq 'my_new_report'
          expect(record.started_at).to eq frozen_time
          expect(record.completed_at).to be_nil
          expect(record.report).to be_nil
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
          described_class.record_start('my_new_report')
        end
      end

      let(:document_content) { 'The contents of my report' }
      let(:start_time) { Time.zone.local(2021, 2, 24, 11, 24, 37) }
      let(:end_time) { Time.zone.local(2021, 2, 24, 11, 29, 12) }
      let(:checksum) { Digest::MD5.new.tap { |digest| digest << document_content }.base64digest }

      it 'copies the document to the document storage' do
        write_report
        expect(File.open(report.document.path).read).to eq document_content
      end

      it 'does not change the started_at time' do
        expect { write_report }.not_to change(report, :started_at)
      end

      it 'updates the completed_at time' do
        expect { write_report }.to change(report, :completed_at).to(end_time)
      end

      it 'sets the report as current' do
        expect { write_report }
          .to change { described_class.completed.where(report_name: 'my_new_report').first }
          .to report
      end

      it 'sets the checksum' do
        expect { write_report }.to change(report, :as_document_checksum).to(checksum)
      end
    end
  end

  describe '#document_url' do
    context 'when document is nil' do
      let(:report) { build(:stats_report, report: nil, document: nil) }

      it { expect(report.document_url).to be_nil }
    end

    context 'when document exists' do
      let(:report) { build(:stats_report, :with_document) }

      context 'when the document storage is filesystem' do
        let(:options) { { storage: :filesystem } }

        before do
          allow(report.document).to receive(:options).and_return(options)
        end

        it 'returns the document path' do
          expect(report.document_url).to eq('tmp/test/reports/report.csv')
        end
      end

      context 'when the document storage is S3' do
        let(:options) { { storage: :s3 } }

        before do
          original_options = report.document.options
          allow(report.document).to receive(:options).and_return(original_options.merge(options))
        end

        it 'returns the an expiring url for the document' do
          expect(report.document_url).to match(%r{tmp/test/reports/report.csv\?([0-9])+})
        end
      end
    end
  end

  describe '#document#path' do
    let(:report) { create :stats_report, document_file_name: 'test_file.csv' }

    before do
      stub_const 'REPORTS_STORAGE_PATH', 'reports/:filename'
    end

    context 'without an Active Storage attachment' do
      it 'has a path based on the filename' do
        expect(report.document.path).to eq 'reports/test_file.csv'
      end
    end

    context 'with an Active Storage attachment in disk storage' do
      require 'active_storage/service/disk_service'

      before do
        ActiveStorage::Attachment.connection.execute(<<~SQL)
          INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
            VALUES('test_key', 'testfile_csv', 100, '{}', 100, 'abc==', NOW())
        SQL
        ActiveStorage::Attachment.connection.execute(<<~SQL)
          INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
            VALUES('document', 'Stats::StatsReport', #{report.id}, LASTVAL(), NOW())
        SQL

        service = ActiveStorage::Service::DiskService.new(root: '/root/')
        allow(ActiveStorage::Blob).to receive(:service).and_return(service)
      end

      it 'has the path for disk storage' do
        expect(report.document.path).to eq '/root/te/st/test_key'
      end
    end

    context 'with an Active Storage attachment in S3' do
      require 'active_storage/service/s3_service'

      before do
        ActiveStorage::Attachment.connection.execute(<<~SQL)
          INSERT INTO active_storage_blobs (key, filename, content_type, metadata, byte_size, checksum, created_at)
            VALUES('test_key', 'testfile_csv', 100, '{}', 100, 'abc==', NOW())
        SQL
        ActiveStorage::Attachment.connection.execute(<<~SQL)
          INSERT INTO active_storage_attachments (name, record_type, record_id, blob_id, created_at)
            VALUES('document', 'Stats::StatsReport', #{report.id}, LASTVAL(), NOW())
        SQL

        service = ActiveStorage::Service::S3Service.new(bucket: 'bucket')
        allow(ActiveStorage::Blob).to receive(:service).and_return(service)
      end

      it 'has the path for disk storage' do
        expect(report.document.path).to eq 'test_key'
      end
    end
  end

  describe 'housekeeping' do
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
