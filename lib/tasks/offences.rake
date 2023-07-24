require Rails.root.join('lib', 'tasks', 'rake_helpers', 'offences_summary.rb')
require 'terminal-table'

namespace :offences do
  desc 'Summary of offences'
  task summary: :environment do
    summary = OffencesSummary.new

    headings = [
      'label',
      'unique code',
      'description',
      *summary.fee_scheme_names
    ]

    table = Terminal::Table.new(headings:) do |t|
      summary.rows.each do |row|
        t.add_row [
          row.label,
          row.unique_code(width: 20),
          row.description(width: 50),
          *row.fee_scheme_flags
        ]
      end
    end

    puts table
  end
end
