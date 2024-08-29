require_relative 'rake_helpers/repair_offences'
require_relative 'rake_helpers/fix_offences'
require_relative 'rake_helpers/rake_utils'
require 'fileutils'

include Tasks::RakeHelpers::RakeUtils

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

  desc 'Extract details of offences and write to a CSV file'
  task :extract, [:dir] => :environment do |_task, args|
    dir = args.dir
    if File.exist?(dir)
      puts "#{dir} already exists"
      exit
    end

    FileUtils.mkdir_p dir

    table_data = [
      { name: 'categories.csv', class: OffenceCategory, fields: %i[id number description] },
      { name: 'bands.csv', class: OffenceBand, fields: %i[id number description offence_category_id] },
      { name: 'classes.csv', class: OffenceClass, fields: %i[id class_letter description] },
      { name: 'offences.csv', class: Offence, fields: %i[id description offence_class_id unique_code offence_band_id contrary year_chapter] },
    ]

    table_data.each do |table|
      data = table[:class].all.sort_by(&:id).pluck(*table[:fields])
      csv_writer(File.expand_path(table[:name], dir), data:, headers: table[:fields])
    end
  end

  desc 'Check details of offences against data in CSV files'
  task :check, [:dir] => :environment do |_task, args|
    dir = args.dir

    Tasks::RakeHelpers::FixOffences.new(dir).check
  end

  desc 'Fix the ids of offences in the database based on data in a CSV file'
  task :fix_ids, [:dir, :live_run] => :environment do |_task, args|
    args.with_defaults(live_run: 'false')
    dir = args.dir
    live_run = ActiveRecord::Type::Boolean.new.deserialize(args.live_run)

    Tasks::RakeHelpers::FixOffences.new(dir, dry_run: !live_run).fix_ids
  end
end
