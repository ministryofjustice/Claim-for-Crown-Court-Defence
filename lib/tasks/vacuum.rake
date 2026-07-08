# frozen_string_literal: true

namespace :db do
  desc 'Perform a full vacuum of the postgres database'
  task :vacuum => :environment do
    puts Rainbow("[#{DateTime.current}]").yellow
    ActiveRecord::Base.connection.execute('VACUUM (VERBOSE, ANALYZE);')
    puts Rainbow("[#{DateTime.current}]").yellow
  end
end
