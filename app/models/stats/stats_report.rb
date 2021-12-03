module Stats
  class StatsReport < ApplicationRecord
    Report = Struct.new(:name, :date_required, keyword_init: true) do
      def initialize(name:, date_required: false)
        super
      end

      def date_required?
        date_required
      end

      def to_s
        name.to_s
      end
    end

    REPORTS = [Report.new(name: 'management_information'),
               Report.new(name: 'agfs_management_information'),
               Report.new(name: 'lgfs_management_information'),
               Report.new(name: 'management_information_v2'),
               Report.new(name: 'agfs_management_information_v2'),
               Report.new(name: 'lgfs_management_information_v2'),
               Report.new(name: 'agfs_management_information_statistics', date_required: true),
               Report.new(name: 'lgfs_management_information_statistics', date_required: true),
               Report.new(name: 'provisional_assessment'),
               Report.new(name: 'rejections_refusals'),
               Report.new(name: 'submitted_claims')].freeze

    validates :status, inclusion: { in: %w[started completed error] }

    default_scope { order('started_at DESC') }

    scope :completed, -> { where(status: 'completed') }
    scope :errored, -> { where(status: 'error') }
    scope :not_errored, -> { where.not(status: 'error') }

    scope :management_information, -> { not_errored.where(report_name: 'management_information') }
    scope :provisional_assessment, -> { not_errored.where(report_name: 'provisional_assessment') }

    before_destroy -> { document.purge }

    has_one_attached :document

    class << self
      def names
        REPORTS.map(&:name)
      end

      def clean_up(report_name)
        destroy_reports_older_than(report_name, 1.month.ago)
        destroy_unfinished_reports_older_than(report_name, 2.hours.ago)
      end

      def most_recent_by_type(report_type)
        where(report_name: report_type).completed.first
      end

      def most_recent_management_information
        management_information.completed.first
      end

      def generation_in_progress?(report_name)
        where('report_name = ? and status = ?', report_name, 'started').any?
      end

      def record_start(report_name)
        create!(report_name: report_name, status: 'started', started_at: Time.now)
      end

      def destroy_reports_older_than(report_name, timestamp)
        where(report_name: report_name, started_at: Time.at(0)..timestamp).destroy_all
      end

      def destroy_unfinished_reports_older_than(report_name, timestamp)
        where(report_name: report_name, status: 'started', started_at: Time.at(0)..timestamp).destroy_all
      end
    end

    def write_report(report_result)
      filename = "#{report_name}_#{started_at.to_s(:number)}.#{report_result.format}"
      log(:info, :write_report, "Writing report #{report_name} to #{filename}")
      document.attach(io: report_result.io, filename: filename, content_type: report_result.content_type)
      update(status: 'completed', completed_at: Time.zone.now)
    rescue StandardError => e
      log(:error, :write_report, "error writing report #{report_name}...", e)
      raise
    end

    def download_filename
      "#{report_name}_#{started_at.to_s(:number)}.csv"
    end

    private

    def log(level, action, message, error = nil)
      LogStuff.send(
        level.to_sym,
        class: self.class.name,
        action: action,
        error: error ? "#{error.class} - #{error.message}" : 'false'
      ) do
        message
      end
    end
  end
end
