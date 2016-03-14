require 'rails_helper'
require 'support/database_housekeeping'


include DatabaseHousekeeping

module Stats

  describe ManagementInformationGenerator do

    before(:all) do
      FileUtils.mkdir ManagementInformationGenerator::STATS_DIR unless Dir.exist?(ManagementInformationGenerator::STATS_DIR)
    end

    let(:generator)  { ManagementInformationGenerator.new }
    after(:each) do
      remove_pidfile
    end


    context 'prevent duplication of running jobs' do
      it 'runs ok if no pidfile present' do
        remove_pidfile
        expect(generator).to receive(:generate_new_report)
        expect(generator).to receive(:delete_old_reports)
        expect(generator).to receive(:clean_up_pidfile)
        
        generator.run
      end

      it 'runs ok if pidfile present but no process with that pid' do
        remove_pidfile
        create_pidfile_with_pid(988773)
        expect(generator).to receive(:generate_new_report)
        expect(generator).to receive(:delete_old_reports)
        expect(generator).to receive(:clean_up_pidfile).exactly(2)
        
        generator.run
      end

      it 'does not run if pidfile present and process with that pid' do
        remove_pidfile
        create_pidfile_with_pid(Process.pid)
        expect(generator).not_to receive(:generate_new_report)
        expect(generator).not_to receive(:delete_old_reports)
        expect(generator).not_to receive(:clean_up_pidfile)

        generator.run
      end
    end

    def remove_pidfile
      pidfile_name
      FileUtils.rm(pidfile_name) if File.exist?(pidfile_name)
    end

    def pidfile_name
      File.join(Rails.root, 'public', 'stats', 'management_information.pid')
    end

    def create_pidfile_with_pid(pid)
      File.open(pidfile_name, 'w') do |fp|
        fp.puts pid.to_s
      end
    end



    describe '.current_csv_filename' do
      before(:each) do
        clear_files
      end

      after(:each) do
        clear_files
      end


      it 'returns the name of the ony csv file in the public/stats directory' do
        create_files('abc_9.csv', 'abc_1.txt')
        expect(ManagementInformationGenerator.current_csv_filename).to eq(File.join(Rails.root, 'public', 'stats', 'abc_9.csv'))
      end
      
      it 'returns the name of the first csv file in the public/stats directory' do
        create_files('abc_9.csv', 'abc_6.csv', 'abc_1.txt')
        expect(ManagementInformationGenerator.current_csv_filename).to eq(File.join(Rails.root, 'public', 'stats', 'abc_6.csv'))
      end

      def create_files(*filenames)
        filenames.each do |filename|
          FileUtils.touch File.join(Rails.root, 'public', 'stats', filename)
        end
      end

      def clear_files
        files = Dir["#{Rails.root}/public/stats/*.csv"]
        FileUtils.rm files
      end
    end

    describe '.creation_time' do
      it 'returns the time parsed from the filename' do
        filename = '/public/stats/management_information_2016_03_01_23_55_59.csv'
        expected_time = Time.new(2016, 3, 1, 23, 55, 59)
        expect(ManagementInformationGenerator.creation_time(filename)).to eq expected_time
      end

      it 'raises if invalid filename' do
        filename = '/public/stats/abd_1.txt'
        expect{ 
          ManagementInformationGenerator.creation_time(filename)
          }.to raise_error ArgumentError, 'Invalid filename for management information file: /public/stats/abd_1.txt'
      end
    end
   
    context 'data generation' do
      before(:all) do
        create :allocated_claim
        create :authorised_claim
        create :part_authorised_claim
        create :draft_claim
        execution_time = Time.new(2016, 3, 10, 11, 44, 55) 
        Timecop.freeze(execution_time) do
          ManagementInformationGenerator.new.run
        end   
      end

      after(:all) do
        clean_database
        FileUtils.rm expected_filename
      end

      it 'creates a file in the public/stats directory' do
        expect(File.exist?(expected_filename)).to be true
      end

      it 'creates a file with a header line and one line for each submitted claim' do
        lines = File.readlines(expected_filename)
        expect(lines.size).to eq 4
      end

      def expected_filename
        "#{Rails.root}/public/stats/management_information_2016_03_10_11_44_55.csv"
      end
    end
  end
end