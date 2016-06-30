
namespace :stats do
  desc 'run all collectors for the past 21 days'
  task :collect => :environment do
    (1..21).each do |offset|
      date = Date.today - offset.days
      Stats::Collector::ClaimSubmissionsCollector.new(date).collect
      Stats::Collector::MultiSessionSubmissionCollector.new(date).collect
      Stats::Collector::InfoRequestCountCollector.new(date).collect
    end
  end
end