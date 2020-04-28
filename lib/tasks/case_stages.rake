namespace :db do
  namespace :seed do
    desc 'Seed case_stages inot the database (case_types must exist for foreign keys)'
    task :case_stages => :environment do
      load("#{Rails.root}/db/seeds/case_stages.rb")
    end
  end
end
