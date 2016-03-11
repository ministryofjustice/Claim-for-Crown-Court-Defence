namespace :db do

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

    # exectute the migrate as a seperate shell task in order that the claims:demo_data task
    # doesn't have stale column information (i.e. recognises the STI columns in Claim and Fee modules)

    pipe = IO.popen('rake db:migrate')
    line = pipe.readline
    while !pipe.eof
      puts line
      line = pipe.readline
    end
    pipe.close


    Rake::Task['claims:demo_data'].invoke
  end


end
