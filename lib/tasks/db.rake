require_relative 'rake_helpers/dump_file_writer'
require_relative 'rake_helpers/s3_bucket'
require_relative 'rake_helpers/rake_utils'
require_relative 'rake_helpers/id_sequence_resettable'
require 'fileutils'
include Tasks::RakeHelpers::RakeUtils

namespace :db do
  namespace :static do
    desc 'Dumps all static data tables to db/static.sql'
    task :dump => :environment do
      raise 'Can only run in development mode' unless Rails.env.development?
      dump_file = "#{Rails.root}/db/static.sql"
      cmd = "pg_dump #{connection_opts} --clean #{static_tables} > #{dump_file}"
      shell_working "exporting static data to #{dump_file}" do
        system cmd
      end
    end

    desc 'restores static data tables on api-sandbox'
    task :restore, [:file] => :environment do |_task, args|
      production_protected

      args.with_defaults(file: "#{Rails.root}/db/static.sql")
      dump_file = args.file

      unless dump_file.present?
        puts 'Please provide the file to restore to the task. Ex: rake db:restore[20160719112847_dump.psql]'
        puts 'Note: if you are using zsh, scape the brackets. Ex: rake db:restore\[20160719112847_dump.psql\]'
        exit(1)
      end

      unless File.exist?(dump_file)
        puts 'File %s not found.' % dump_file
        exit(1)
      end

      shell_working "importing static data dump file #{dump_file}" do
        system (with_config do |_db_name, connection_opts|
          "PGPASSWORD=#{ActiveRecord::Base.connection_config[:password]} psql -q -P pager=off #{connection_opts} -f #{dump_file} >/dev/null"
        end)
      end
    end
  end

  desc "Erase all tables"
  task :clear => :environment do
    production_protected

    conn = ActiveRecord::Base.connection
    tables = conn.tables
    tables.each do |table|
      puts "Deleting #{table}"
      conn.drop_table(table, force: :cascade)
    end
  end

  desc 'CCCD task: clear the database, run migrations and seeds'
  task :reseed => [:clear, 'db:migrate', 'db:seed']

  desc 'CCCD task: clear the database, run migrations, seeds and reloads demo data'
  task reload: :environment do
    production_protected

    Rake::Task['db:clear'].invoke
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
  end

  desc 'Dumps an unuanonymised backup of the database'
  task :dump_unanonymised => :environment do
    system (with_config do |db_name, connection_opts|
      "pg_dump $DATABASE_URL -v --no-owner --no-privileges --no-password #{connection_opts} -f #{Time.now.strftime('%Y%m%d%H%M%S')}_#{db_name}.psql"
    end)
  end

  desc 'Anonymise current database data (in-place, no dump)'
  task :anonymise => :environment do
    production_protected

    shell_working "anonymising data in place" do
      system (with_config do |_db_name, connection_opts|
        "PGPASSWORD=#{ActiveRecord::Base.connection_config[:password]} psql -v translation=\\'#{translation}\\' #{connection_opts} -f #{Rails.root}/db/data/anonymise_db.sql"
      end)
    end
  end

  desc 'Restores the database from a backup'
  task :restore, [:file] => :environment do |_task, args|
    production_protected
    include Tasks::RakeHelpers::IdSequenceResettable

    dump_file = args.file

    unless dump_file.present?
      puts 'Please provide the file to restore to the task. Ex: rake db:restore[20160719112847_dump.psql]'
      puts 'Note: if you are using zsh, scape the brackets. Ex: rake db:restore\[20160719112847_dump.psql\]'
      exit(1)
    end

    unless File.exist?(dump_file)
      puts 'File %s not found.' % dump_file
      exit(1)
    end

    if dump_file.end_with?('.gz')
      decompress_file(dump_file)
      dump_file = dump_file[0..-4]
    end

    shell_working 'Appending sequence resets in dump file...' do
      append_sequence_resets(dump_file)
    end

    shell_working 'Setting search path in dump file...' do
      set_pg_search_path(dump_file)
    end

    shell_working 'recreating schema' do
      system (with_config do |_db_name, connection_opts|
          "PGPASSWORD=#{ActiveRecord::Base.connection_config[:password]} psql -q -P pager=off #{connection_opts} -c \"drop schema public cascade\""
        end)
      system (with_config do |_db_name, connection_opts|
        "PGPASSWORD=#{ActiveRecord::Base.connection_config[:password]} psql -q -P pager=off #{connection_opts} -c \"create schema public\""
      end)
    end

    shell_working "importing dump file #{dump_file}" do
      system (with_config do |_db_name, connection_opts|
        "PGPASSWORD=#{ActiveRecord::Base.connection_config[:password]} psql -q -P pager=off #{connection_opts} -f #{dump_file} > /dev/null"
      end)
    end
  end

  private

  def translation
    [('a'..'z'), ('A'..'Z')].map(&:to_a).map(&:shuffle).join
  end

  def with_config
    yield ActiveRecord::Base.connection_config[:database], connection_opts
  end

  def connection_opts
    [
      ['-U', ActiveRecord::Base.connection_config[:username]],
      ['-h', ActiveRecord::Base.connection_config[:host]],
      ['-d', ActiveRecord::Base.connection_config[:database]]
    ].inject([]) do |result, (flag, value)|
      result.push([flag, value]) unless (value.nil? || value.empty?)
      result
    end.join(' ')
  end

  def static_tables
    '-t courts -t case_types -t disbursement_types -t expense_types -t fee_types -t offence_classes -t offences'
  end

  # OPTIMIZE: https://stackoverflow.com/questions/148451/how-to-use-sed-to-replace-only-the-first-occurrence-in-a-file/11458836#11458836
  # required because of this change
  # https://www.postgresql.org/about/news/postgresql-103-968-9512-9417-and-9322-released-1834/
  # NOTE: this is POSIX compliant so that BSD (osx) and GNU sed can be used
  def set_pg_search_path(dump_file)
    `sed -e "s/SELECT pg_catalog.set_config('search_path', '', false)/SELECT pg_catalog.set_config('search_path', 'public, pg_catalog', true)/" #{dump_file} > #{dump_file}.tmp`
    `mv -- #{dump_file}.tmp #{dump_file}`
  end
end
