
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

  desc 'number of claims where VAT paid is higher than VAT claimed'
  task :vat => :environment do
    time_window = [Time.now-6.months..Time.now]
    precision_error = 1

    claim_ids = []
    claimed_vat = []
    claimed_gt_vat = []
    paid_gt_vat = []
    paid_vat = []

    Claim::BaseClaim.where(state: %w(authorised part_authorised), last_submitted_at: time_window).includes(
        :assessment, :determinations, :redeterminations).find_each(batch_size: 50) do |claim|

      assessment = claim.last_redetermination || claim.assessment

      claimed_vat << claim.vat_amount
      paid_vat << assessment.vat_amount

      if assessment.vat_amount.to_f > (claim.vat_amount.to_f + precision_error) && assessment.total.to_f <= claim.total.to_f
        claimed_gt_vat << claim.vat_amount
        paid_gt_vat << assessment.vat_amount
        claim_ids << claim.id
      end

      puts 'Processing. Please wait...' if claimed_vat.size % 1000 == 0
    end

    percentage = ((paid_gt_vat.size * 100) / claimed_vat.size.to_f).round(2)

    puts 'Total claims authorised or part_authorised in the last 6 months: %s' % claimed_vat.size
    puts 'Paid VAT greater than claimed: %s (%s%%)' % [paid_gt_vat.size, percentage]
    puts 'Average claimed VAT: %s - Average paid VAT: %s' % [claimed_gt_vat.average.round(2), paid_gt_vat.average.round(2)]
    puts
    puts "Claim IDs: #{claim_ids.sort}"
    puts
  end
end