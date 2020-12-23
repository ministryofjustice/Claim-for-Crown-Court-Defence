require_relative 'rake_helpers/dump_file_writer'
require_relative 'rake_helpers/s3_bucket'
require_relative 'rake_helpers/rake_utils'
require 'fileutils'
require 'open3'

include RakeUtils

namespace :db do
  namespace :dump do
    desc <<~ldesc
    Run dump file job from local machine
      * requires kubectl and access to git-crypted secrets
      Usage:
      # runs dump job against staging using latest master branch build
      rake db:dump:run_job['staging']

      # # runs dump job against dev using my-branch-latest build
      rake db:dump:run_job['dev','my-branch-latest']
    ldesc
    task :run_job, [:host, :build_tag] => :environment do |_task, args|
      host = args.host
      build_tag = args.build_tag || 'latest'
      raise ArgumentError.new('invalid host') unless valid_hosts.include?(host)

      script = Rails.root.join('kubernetes_deploy', 'scripts', 'job.sh')

      cmd = "#{script} dump #{host} #{build_tag}"
      Open3.popen2e(cmd) do |stdin, stdout_and_stderr, wait_thr|
        stdout_and_stderr.each_line do |line|
          puts line
        end
        raise ['Failure'.red, ': ', cmd].join unless wait_thr.value.success?
      end

      continue?'Do you want to delete all but the latest dump file from s3?'
      Rake::Task['db:dump:delete_s3_dumps'].invoke(host)
    end

    desc 'Create anonymised database dump, compress (gzip) and upload to s3 - run on host via job (see run_job)'
    task :anonymised => :environment do
      cmd = 'pg_dump --version'
      puts '---------------------------'
      print "Using: #{%x(#{cmd})}".yellow
      host = Rails.host.env
      puts "Host environment: #{host || 'not set'}"
      filename = File.join('tmp', "#{Time.now.strftime('%Y%m%d%H%M%S')}_dump.psql")

      shell_working "exporting unanonymised database data to #{filename}..." do
        cmd = "pg_dump $DATABASE_URL --no-owner --no-privileges --no-password #{sensitive_table_exclusions} -f #{filename}"
        system(cmd)
      end

      # $arel_silence_type_casting_deprecation = true
      excluded_tables.each do |table|
        task_name = "db:dump:#{table}"
        Rake::Task[task_name].invoke(filename)
      end
      # $arel_silence_type_casting_deprecation = false

      compressed_file = compress_file(filename)

      shell_working "writing dump file #{filename}.gz to #{host}'s s3 bucket..." do
        s3_bucket = S3Bucket.new(host)
        s3_bucket.put_object(compressed_file, File.read(compressed_file))
      end

      Rake::Task['db:dump:list_s3_dumps'].invoke(Rails.host.env)
    end

    desc 'List s3 database dump files'
    task :list_s3_dumps, [:host] => :environment do |_task, args|
      require 'action_view'
      include ActionView::Helpers::NumberHelper

      host = args.host
      raise ArgumentError.new("invalid host #{host}") unless valid_hosts.include?(host)

      s3_bucket = S3Bucket.new(host)
      dump_files = s3_bucket.list('tmp').select { |item| item.key.match?('dump') }

      abort('No dump files found!'.yellow) if dump_files.empty?

      puts "------------list of dump files on #{host}----------------"
      dump_files.sort_by(&:last_modified).reverse.map do |object|
        puts "Key: #{object.key}"
        puts "Last modified: #{object.last_modified.iso8601}"
        puts "Size: #{number_to_human_size(object.content_length)}"
        puts '-----------------------------------------------------'
      end
    end

    desc 'Delete all but latest s3 database dump files'
    task :delete_s3_dumps, [:host, :all] => :environment do |_task, args|
      host = args.host
      start = args.all.eql?('all') ? 0 : 1

      raise ArgumentError.new("invalid host #{host}") unless valid_hosts.include?(host)

      s3_bucket = S3Bucket.new(host)
      dump_files = s3_bucket.list('tmp').select { |item| item.key.match?('dump') }
      dump_files.sort_by(&:last_modified).reverse[start..].map do |object|
        print "Deleting #{object.key}..."
        object.delete
        puts 'done'.green
      end
    end

    desc 'Copy s3 bucket dump file locally and decompress'
    task :copy_s3_dump, [:key, :host] => :environment do |_task, args|
      dump_file, host = args.key, args.host
      raise ArgumentError.new('invalid host') unless valid_hosts.include?(host)

      # stream object directly
      # https://aws.amazon.com/blogs/developer/downloading-objects-from-amazon-s3-using-the-aws-sdk-for-ruby/
      dirname = Rails.root.join('tmp', "#{host}")
      FileUtils.mkpath(dirname)
      local_filename = dirname.join(dump_file.split(File::Separator).last)

      s3_bucket = S3Bucket.new(host)
      shell_working "Copying S3 file #{dump_file} to local file #{local_filename} data" do
        File.open(local_filename, 'wb') do |file|
          reap = s3_bucket.get_object(dump_file, target: file)
        end
      end

      decompress_file(local_filename)
    end

    desc 'Export anonymised providers data'
    task :providers, [:file] => :environment do |task, args|
      shell_working "exporting anonymised #{task.name.split(':').last} data" do
        write_to_file(args.file) do |writer|
          Provider.find_each(batch_size: batch_size) do |provider|
            provider.name = [Faker::Company.name, provider.id].join(' ')
            writer.call(provider)
          end
        end
      end
    end

    desc 'Export anonymised defendants data'
    task :defendants, [:file] => :environment do |task, args|
      shell_working "exporting anonymised #{task.name.split(':').last} data" do
        write_to_file(args.file) do |writer|
          Defendant.find_each(batch_size: batch_size) do |defendant|
            defendant.first_name = Faker::Name.first_name
            defendant.last_name = Faker::Name.last_name
            writer.call(defendant)
          end
        end
      end
    end

    desc 'Export anonymised users data'
    task :users, [:file] => :environment do |task, args|
      shell_working "exporting anonymised #{task.name.split(':').last} data" do
        whitelist_domains = %w(example.com agfslgfs.com)

        write_to_file(args.file) do |writer|
          User.find_each(batch_size: batch_size) do |user|
            user.encrypted_password = '$2a$10$r4CicQylcCuq34E1fysqEuRlWRN4tiTPUOHwksecXT.hbkukPN5F2'
            unless whitelist_domains.detect { |domain| user.email.end_with?(domain) }
              user.first_name = Faker::Name.first_name
              user.last_name = Faker::Name.last_name
              user.email = "#{user.id}@anonymous.com"
            end

            writer.call(user)
          end
        end
      end
    end

    desc 'Export anonymised messages data'
    task :messages, [:file] => :environment do |task, args|
      shell_working "exporting anonymised #{task.name.split(':').last} data" do
        write_to_file(args.file) do |writer|
          Message.find_each(batch_size: batch_size) do |message|
            message.body = Faker::Lorem.sentence(word_count: 6, supplemental: false, random_words_to_add: 10)
            if message.attachment_file_name.present?
              message.attachment_file_name = fake_file_name(message.attachment_file_name)
            end
            writer.call(message)
          end
        end
      end
    end

    desc 'Export anonymised document data'
    task :documents, [:file] => :environment do |task, args|
      shell_working "exporting anonymised #{task.name.split(':').last} data" do
        write_to_file(args.file) do |writer|
          Document.find_each(batch_size: batch_size) do |document|
            with_file_name(fake_file_name(document.document_file_name)) do |file_name, ext|
              document.document_file_name = "#{file_name}.#{ext}"
              document.converted_preview_document_file_name = "#{file_name}#{ '.' + ext unless ext == 'pdf' }.pdf"
              document.file_path = "/s3/path/to/#{file_name}.#{ext}"
            end
            writer.call(document)
          end
        end
      end
    end

    desc 'Export anonymised claims data'
    task :claims, [:file] => :environment do |task, args|
      shell_working "exporting anonymised #{task.name.split(':').last} data" do
        write_to_file(args.file) do |writer|
          Claim::BaseClaim.find_each(batch_size: batch_size) do |claim|
            claim.travel_expense_additional_information = fake_paragraphs if claim.travel_expense_additional_information.present?
            claim.additional_information = fake_paragraphs if claim.additional_information.present?
            claim.providers_ref = claim.providers_ref.tr('a-zA-Z', translation) if claim.providers_ref.present?
            writer.call(claim)
          end
        end
      end
    end

    private

    def valid_hosts
      %w[dev dev-lgfs staging api-sandbox production]
    end

    def excluded_tables
      %w(providers users claims defendants messages documents)
    end

    def sensitive_table_exclusions
      # make sure a db:dump task exists for each of the excluded tables (i.e. db:dump:providers)
      excluded_tables.map { |table| "--exclude-table-data #{table}" }.join(' ')
    end

      def fake_file_name original_file_name
      *file_parts, _last = Faker::File.file_name.gsub(/\//,'_').split('.')
      file_parts.join + '.' + original_file_name.split('.').last
    end

    def with_file_name file_name, &block
      *file_name, ext = file_name.split('.')
      yield file_name.join, ext if block_given?
    end

    def fake_paragraphs max_paragraph_count=4
      Faker::Lorem.paragraphs(number: max_paragraph_count).pop(rand(1..max_paragraph_count)).join("\n")
    end

    def translation
      [('a'..'z'), ('A'..'Z')].map(&:to_a).map(&:shuffle).join
    end

    def write_to_file(name)
      writer = DumpFileWriter.new(name)
      yield -> (model) do
        writer.model = model
        writer.write
      end
    end

    # optimum determined from benchmarking
    def batch_size
      @batch_size ||= 200
    end
  end
end
