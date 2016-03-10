require 'csv'

module Stats

  class ManagementInformationGenerator

    STATS_DIR = Rails.env.test? ? File.join(Rails.root, 'public', 'stats') : File.join(Rails.root, 'tmp', 'stats')
    PIDFILE_NAME = File.join(STATS_DIR, 'management_information.pid')

    def initialize
      FileUtils.mkdir STATS_DIR unless Dir.exist?(STATS_DIR)
      @filename = File.join(STATS_DIR, "management_information_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}.csv")
    end

    def run
      if drop_pidfile_ok?
        generate_new_report
        delete_old_reports
        clean_up_pidfile
      end
    end

    def self.current_csv_filename
      files = files = Dir["#{STATS_DIR}/**/*.csv"]
      files.sort.first           # return the first file, because if there are two, then the second hasn't finished generating
    end


    def self.creation_time(filename)
      unless filename =~ /management_information_(\d{4})_(\d{2})_(\d{2})_(\d{2})_(\d{2})_(\d{2})\.csv$/
        raise ArgumentError.new("Invalid filename for management information file: #{filename}")
      end
      Time.new($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i)
    end

  private
    def drop_pidfile_ok?
      if pidfile_exists? 
        return false if duplicate_job_running?
        clean_up_pidfile
      end
      create_pidfile
      true
    end 

    def pidfile_exists?
      File.exist?(PIDFILE_NAME)
    end

    def duplicate_job_running?
      pid = File.read(PIDFILE_NAME).chomp
      active_process_with_pid?(pid)
    end

    def clean_up_pidfile
      FileUtils.rm PIDFILE_NAME
    end

    def active_process_with_pid?(pid)
      begin
        Process.getpgid(pid.to_i)
        true
      rescue Errno::ESRCH
        false
      end
    end

    def create_pidfile
      File.open(PIDFILE_NAME, 'w') do |fp|
        fp.puts Process.pid
      end
    end


    def delete_old_reports
      files = Dir["#{STATS_DIR}/**/*.csv"] - [ @filename ]
      FileUtils.rm files
    end

    def generate_new_report
      CSV.open(@filename, "wb") do |csv|
        csv << Settings.claim_csv_headers.map {|header| header.to_s.humanize}
        Claim::BaseClaim.non_draft.find_each do |claim|
          ClaimCsvPresenter.new(claim, 'view').present! do |claim_journeys|
            claim_journeys.each do |claim_journey|
              csv << claim_journey
            end
          end
        end
      end
    end

  end
end