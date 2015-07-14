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

  desc 'clear the database, run migrations and seeds'
  task :reseed => [:clear, 'db:migrate', 'db:seed'] do

  end

  desc 'clear the database, run migrations, seeds and reloads demo data'
  task :reload => [:clear, 'db:migrate', 'claims:demo_data'] do

  end

end
