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

      unless File.exists?(dump_file)
        puts 'File %s not found.' % dump_file
        exit(1)
      end

      shell_working "importing static data dump file #{dump_file}" do
        system (with_config do |_db_name, connection_opts|
          "PGPASSWORD=$DB_PASSWORD psql -q -P pager=off #{connection_opts} -f #{dump_file} >/dev/null"
        end)
      end
    end
  end

  desc "Erase all tables"
  task :clear => :environment do
    conn = ActiveRecord::Base.connection
    tables = conn.tables
    tables.each do |table|
      puts "Deleting #{table}"
      conn.drop_table(table, force: :cascade)
    end
  end

  desc 'ADP task: clear the database, run migrations and seeds'
  task :reseed => [:clear, 'db:migrate', 'db:seed'] {}

  desc 'ADP task: clear the database, run migrations, seeds and reloads demo data'
  task :reload do
    Rake::Task['db:clear'].invoke
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['claims:demo_data'].invoke
  end

  desc 'Dumps a backup of the database'
  task :dump => :environment do
    system (with_config do |db_name, connection_opts|
      "PGPASSWORD=$DB_PASSWORD pg_dump -v -O -x -w #{connection_opts} -f #{Time.now.strftime('%Y%m%d%H%M%S')}_#{db_name}.psql"
    end)
  end

  desc 'Dumps an anonymised (gzip) backup of the database'
  task :dump_anonymised, [:file] => :environment do |_task, args|
    excluded_tables = %w(providers defendants users messages documents) # make sure a db:dump task exists for each of these tables (i.e. db:dump:providers)

    exclusions = excluded_tables.map { |table| "--exclude-table-data #{table}" }.join(' ')
    filename = args.file || "#{Time.now.strftime('%Y%m%d%H%M%S')}_dump.psql"

    shell_working 'exporting unanonymised database data' do
      system (with_config do |_db_name, connection_opts|
        "PGPASSWORD=$DB_PASSWORD pg_dump -O -x -w #{exclusions} #{connection_opts} -f #{filename}"
      end)
    end

    # The following will export the previously excluded tables data, in an anonymised way
    excluded_tables.each do |table|
      task_name = "db:dump:#{table}"
      Rake::Task[task_name].invoke(filename)
    end

    compress_file(filename)
  end

  desc 'Anonymise current database data (in-place, no dump)'
  task :anonymise => :environment do
    production_protected

    translation = [('a'..'z'), ('A'..'Z')].map(&:to_a).map(&:shuffle).join

    shell_working "anonymising data in place" do
      system (with_config do |_db_name, connection_opts|
        "PGPASSWORD=$DB_PASSWORD psql -v translation=\\'#{translation}\\' #{connection_opts} -f #{Rails.root}/db/data/anonymise_db.sql"
      end)
    end
  end

  desc 'Restores the database from a backup'
  task :restore, [:file] => :environment do |_task, args|
    production_protected

    dump_file = args.file

    unless dump_file.present?
      puts 'Please provide the file to restore to the task. Ex: rake db:restore[20160719112847_dump.psql]'
      puts 'Note: if you are using zsh, scape the brackets. Ex: rake db:restore\[20160719112847_dump.psql\]'
      exit(1)
    end

    unless File.exists?(dump_file)
      puts 'File %s not found.' % dump_file
      exit(1)
    end

    if dump_file.end_with?('.gz')
      decompress_file(dump_file)
      dump_file = dump_file[0..-4]
    end

    shell_working 'recreating schema' do
      system (with_config do |_db_name, connection_opts|
          "PGPASSWORD=$DB_PASSWORD psql -q -P pager=off #{connection_opts} -c \"drop schema public cascade\""
        end)
      system (with_config do |_db_name, connection_opts|
        "PGPASSWORD=$DB_PASSWORD psql -q -P pager=off #{connection_opts} -c \"create schema public\""
      end)
    end

    shell_working "importing dump file #{dump_file}" do
      system (with_config do |_db_name, connection_opts|
        "PGPASSWORD=$DB_PASSWORD psql -q -P pager=off #{connection_opts} -f #{dump_file} > /dev/null"
      end)
    end

  end

  namespace :dump do
    desc 'Export anonymised providers data'
    task :providers, [:file] => :environment do |task, args|
      shell_working "exporting anonymised #{task.name.split(':').last} data" do
        write_to_file(args.file) do |writer|
          Provider.find_each(batch_size: 50) do |provider|
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
          Defendant.find_each(batch_size: 50) do |defendant|
            defendant.first_name = Faker::Name.first_name
            defendant.last_name  = Faker::Name.last_name
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
          User.find_each(batch_size: 50) do |user|
            user.encrypted_password = '$2a$10$r4CicQylcCuq34E1fysqEuRlWRN4tiTPUOHwksecXT.hbkukPN5F2'

            unless whitelist_domains.detect { |domain| user.email.end_with?(domain) }
              user.first_name = Faker::Name.first_name
              user.last_name  = Faker::Name.last_name
              user.email = [user.id, '@', 'example.com'].join
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
          Message.find_each(batch_size: 50) do |message|
            message.body = Faker::Lorem.sentence(6, false, 10)
            if message.attachment_file_name.present?
              message.attachment_file_name = fake_attachment_file_name(message.attachment_file_name)
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
          Document.find_each(batch_size: 100) do |document|
            with_file_name(fake_attachment_file_name(document.document_file_name)) do |file_name, ext|
              document.document_file_name = "#{file_name}.#{ext}"
              document.converted_preview_document_file_name = "#{file_name}#{ '.' + ext unless ext == 'pdf' }.pdf"
            end
            writer.call(document)
          end
        end
      end
    end
  end

  private

  def shell_working message = 'working', &block
    ShellSpinner message do
      yield
    end
  end

  def production_protected
    raise 'This operation was aborted because the result might destroy production data' if ActiveRecord::Base.connection_config[:database] =~ /gamma/
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

  def write_to_file(name)
    file_name = name || 'anonymised_data.sql'

    open(file_name, 'a') do |file|
      yield ->(model) do
        file.puts model.class.arel_table.create_insert.tap { |im| im.insert(model.send(:arel_attributes_with_values_for_create, model.attribute_names)) }.to_sql.gsub('"', '') + ';'
      end
    end
  end

  def compress_file(filename)
    shell_working "compressing file #{filename}" do
      system "gzip #{filename}"
    end
  end

  def decompress_file(filename)
    shell_working "decompressing file #{filename}" do
      system "gzip -d #{filename}"
    end
  end

  def static_tables
    '-t courts -t case_types -t disbursement_types -t expense_types -t fee_types -t offence_classes -t offences'
  end

  def fake_attachment_file_name original_file_name
    *file_parts, _last = Faker::File.file_name.gsub(/\//,'_').split('.')
    file_parts.join + '.' + original_file_name.split('.').last
  end

  def with_file_name file_name, &block
    *file_name, ext = file_name.split('.')
    yield file_name.join, ext if block_given?
  end

end
