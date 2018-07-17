namespace :establishments do
  desc 'Seed establishments into the database (prefix with SEEDS_DRY_MODE=false to disable DRY mode)'
  task :seed => :environment do
    ENV['SEEDS_DRY_MODE'] = 'true' unless ENV['SEEDS_DRY_MODE'].present?
    load("#{Rails.root}/db/seeds/establishments.rb")
  end
end
