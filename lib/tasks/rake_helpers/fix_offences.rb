require_relative 'rake_utils'
include Tasks::RakeHelpers::RakeUtils

module Tasks
  module RakeHelpers
    class FixOffences      
      def initialize(dir, dry_run: true)
        @dir = dir
        @data_sets = [
          { name: 'categories', class: OffenceCategory, fields: %i[id number description] },
          { name: 'bands', class: OffenceBand, fields: %i[id number description offence_category_id] },
          { name: 'classes', class: OffenceClass, fields: %i[id class_letter description] },
          { name: 'offences', class: Offence, fields: %i[id description offence_class_id unique_code offence_band_id contrary year_chapter] },
        ]
        @dry_run = dry_run
      end

      def check
        @data_sets.each do |set|
          puts set[:name].capitalize.blue
          output(set[:name].capitalize)
          check_counts(set)
          check_records(set)
          puts '---------------'
          output('---------------')
        end
      end

      def fix_ids
        puts "[DRY RUN]".blue if @dry_run

        puts "Offences count before: #{Offence.count}".green
        csv_data = CSV.read(File.expand_path('offences.csv', @dir), headers: true)
        offset = Offence.maximum(:id) + 10000
        Offence.transaction do
          puts 'FIRST PASS - Move records with incorrect ids out of range'.yellow
          db_records = []
          new_records = []
          ids = []

          csv_data.each do |csv_record|
            db_record = Offence.find_by(csv_record.to_h.except('id'))
            if db_record.nil?
              new_records << csv_record
            else
              if db_record.id.to_s != csv_record['id']
                claims = db_record.claims

                print "Setting id #{db_record.id} to #{csv_record['id'].to_i + offset}\r".red
                db_record.id = csv_record['id'].to_i + offset
                db_record.save

                claims.update_all(offence_id: db_record.id)

                db_records << db_record
              end
              ids << db_record.id
            end
          end
          print "                              \r"

          puts 'SECOND PASS - Remove extra records'.yellow
          extras = Offence.where.not(id: ids)
          extras.delete_all

          puts 'THIRD PASS - Add missing records'.yellow
          new_records.each do |record|
            offence = Offence.new(record.to_h.except('id'))
            offence.save
            offence.id = record['id']
            offence.save
          end

          puts 'FOURTH PASS - Move records that had incorrect ids into their correct range'.yellow
          db_records.each do |db_record|
            claims = db_record.claims

            print "Setting id #{db_record.id} to #{db_record.id - offset}\r".red
            db_record.id = db_record.id - offset
            db_record.save

            claims.update_all(offence_id: db_record.id)
          end
          print "                              \r"

          puts "Offences count after: #{Offence.count}".green

          if @dry_run
            puts "[ROLLING BACK]".blue
            raise ActiveRecord::Rollback
          end
        end
      end

      private

      def check_counts(set)
        csv_data = CSV.read(File.expand_path("#{set[:name]}.csv", @dir), headers: true)
        puts "Number of #{set[:name]} in CSV file: #{csv_data.count}".yellow
        puts "Number of #{set[:name]} in database: #{set[:class].count}".yellow
        puts csv_data.count == set[:class].count ? '  [OK]'.green : '  [MISMATCH]'.red
      end

      def check_records(set)
        puts "Matches:".yellow
        csv_data = CSV.read(File.expand_path("#{set[:name]}.csv", @dir), headers: true)

        missing = []
        incorrect = []
        extras = []
        csv_data.each do |csv_record|
          db_record = set[:class].find_by(csv_record.to_h.except('id'))
          if db_record
            if csv_record['id'] != db_record['id'].to_s
              incorrect << [csv_record, db_record]
            end
            extras << db_record['id']
          else
            missing << csv_record
          end
        end
        puts "#{missing.count} records in production not found in this environment".yellow
        puts "#{incorrect.count} records in production found in this environment with an incorrect id".yellow
        extras = set[:class].where.not(id: extras)
        puts "#{extras.count} records in this environment and not in production".yellow
        output('Missing records:') if missing.count.positive?
        missing.each do |record|
          output("#{record['id']}")
          set[:fields].each do |field|
            output("  #{field}: #{record[field.to_s]}")
          end
        end
        output()
        output('Extra records:') if extras.count.positive?
        extras.each do |record|
          output("#{record['id']}")
          set[:fields].each do |field|
            output("  #{field}: #{record[field.to_s]}")
          end
          output("  Number of claims with this offence: #{record.claims.count}")
        end
        output()
        output('Incorrect records:') if incorrect.count.positive?
        incorrect.each do |record|
          output("#{record[0]['id']} (CSV) - #{record[1]['id']} (DB)")
          set[:fields].each do |field|
            output("  #{field}: #{record[0][field.to_s]}")
          end
          output("  Number of claims with this offence: #{record[1].claims.count}")
        end
      end

      def output(line='') = File.write(File.expand_path('output.log', @dir), "#{line}\n", mode: 'a+')
    end
  end
end
