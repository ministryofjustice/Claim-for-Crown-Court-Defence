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

  desc 'clear the database, run migrations and reload demo data'
  task :reload => [:clear, 'db:migrate', 'claims:demo_data'] do

  end
end
