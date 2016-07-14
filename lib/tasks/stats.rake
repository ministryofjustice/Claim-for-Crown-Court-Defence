
namespace :stats do
  desc 'run all collectors for the past 21 days'
  task :collect => :environment do
    (1..21).each do |offset|
      date = Date.today - offset.days
      Stats::Collector::ClaimCreationSourceCollector.new(date).collect
      Stats::Collector::ClaimSubmissionsCollector.new(date).collect
      Stats::Collector::MultiSessionSubmissionCollector.new(date).collect
      Stats::Collector::InfoRequestCountCollector.new(date).collect
      Stats::Collector::TimeFromRejectToAuthCollector.new(date).collect
      Stats::Collector::CompletionRateCollector.new(date).collect
      Stats::Collector::TimeToCompletionCollector.new(date).collect
      Stats::Collector::ClaimRedeterminationsCollector.new(date).collect
    end

    # and this one just has to be run the once
    Stats::Collector::MoneyToDateCollector.new(Date.today).collect

    # and this one we run just once per month for the last day of each month.
    date = Date.new(2015, 11, 1)
    while date < Date.today do
      Stats::Collector::MoneyClaimedPerMonthCollector.new(date).collect
      date += 1.month
    end
  end
end