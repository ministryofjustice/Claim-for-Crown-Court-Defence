namespace :demo do

  task :data => :environment do
    require "#{Rails.root}/lib/demo_data/claim_generator.rb"
    DemoData::ClaimGenerator.new


  end
  
end