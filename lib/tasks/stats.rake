
namespace :stats do
  task :collect => :environment do
    (1..21).each do |offset|
      date = Date.today - offset.days
      Stats::Collector::ClaimSubmissionsCollector.new(date).collect
    end
  end
end