namespace :clone do
  desc 'Repairs attached files not properly cloned'
  task :repair => :environment do
    claim_ids = CloneRepairRunner.new.run
  end
end

