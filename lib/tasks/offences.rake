require 'terminal-table'

namespace :offences do
  desc 'Summary of offences'
  task summary: :environment do
    summary = OffencesSummaryService.call

    headings = [
      'label',
      'unique code',
      'description',
      *summary.fee_scheme_headings
    ]

    table = Terminal::Table.new(headings:) do |t|
      summary.each do |row|
        t.add_row [
          row.label,
          row.unique_code(width: 20),
          row.description(width: 50),
          *row.fee_scheme_flags.map { |flag| flag ? '*******' : '' }
        ]
      end
    end

    puts table
  end
end
