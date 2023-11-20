require_relative 'rake_helpers/repair_offences'
require 'csv'

namespace :offences do
  desc 'Generate repair input file of claim id against offence id based on data from CCR'
  task :generate_repair_input, [:filename, :output, :interactive] => :environment do |_task, args|
    interactive = args.interactive != 'false'

    repair = Tasks::RakeHelpers::RepairOffences.new(file: args.filename, output: args.output, interactive:)
    repair.generate
  end

  desc 'Repair claims by reattaching offencees'
  task :repair, [:filename, :output, :dry_run, :interactive] => :environment do |_task, args|
    interactive = args.interactive != 'false'
    dry_run = args.dry_run != 'false'

    repair = Tasks::RakeHelpers::RepairOffences.new(file: args.filename, output: args.output, interactive:, dry_run:)
    repair.repair
  end
end
