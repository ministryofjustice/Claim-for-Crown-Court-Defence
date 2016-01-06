namespace :db do

  desc "Erase all tables"
  task :clear => :environment do
    conn = ActiveRecord::Base.connection
    tables = conn.tables
    tables.each do |table|
      puts "Deleting #{table}"
      conn.drop_table(table)
    end
  end

  desc 'ADP task: clear the database, run migrations and seeds'
  task :reseed => [:clear, 'db:migrate', 'db:seed'] {}

  desc 'ADP task: clear the database, run migrations, seeds and reloads demo data'
  task :reload => [:clear, 'db:migrate', 'claims:demo_data'] {}

  namespace :data do

    desc 'ADP task: migrate offence to full offence list seeds and update claims'
    task :migrate_offences => :environment do
      require Rails.root.join('lib', 'offence_migration')
      om = OffenceMigration.new()
      om.up
    end
  end

end
