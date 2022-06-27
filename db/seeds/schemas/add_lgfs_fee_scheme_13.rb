# Class to:
# 1. create lgfs fee scheme 13
# 2. add an end date to fee scheme 9 (day before scheme 13 start)
# 3. copy all fee scheme 9 offences, creating as fee scheme 13 records
# 4. create offence fee scheme through table records to associate each
#    with an fee scheme.
#
module Seeds
  module Schemas
    class AddLgfsFeeScheme13
      attr_reader :pretend
      alias_method :pretending?, :pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
         <<~STATUS
          \sLGFS scheme 9 start date: #{lgfs_fee_scheme_9&.start_date || 'nil'}
          \sLGFS scheme 9 end date: #{lgfs_fee_scheme_9&.end_date || 'nil'}
          \sLGFS scheme 13 start date: #{lgfs_fee_scheme_13&.start_date || 'nil'}
          \sLGFS scheme 13 fee scheme: #{lgfs_fee_scheme_13&.attributes || 'nil'}
          \sLGFS scheme 13 offence count: #{scheme_13_offence_count}
          \sLGFS scheme 13 total fee_type count: #{scheme_13_fee_type_count}
          \s------------------------------------------------------------
          Status: #{lgfs_fee_scheme_13.present? && scheme_13_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        create_or_update_lgfs_scheme_nine
        create_lgfs_scheme_thirteen
        create_lgfs_scheme_thirteen_offences
        create_lgfs_scheme_thirteen_fee_types
      end

      def down
        destroy_lgfs_scheme_thirteen_offences
        remove_lgfs_scheme_thirteen_fee_type_roles
        destroy_lgfs_scheme_thirteen
        rollback_scheme_nine
      end

      private

      def lgfs_fee_scheme_13
        @lgfs_fee_scheme_13 ||= FeeScheme.lgfs.thirteen.first
      end

      def lgfs_fee_scheme_9
        @lgfs_fee_scheme_9 ||= FeeScheme.lgfs.nine.first
      end

      def destroy_lgfs_scheme_thirteen_offences
        if pretending?
          puts "Would delete #{scheme_13_offence_count} scheme 13 offences".yellow
          puts "Would reset offence PK sequence to max id value: #{Offence.ids.max}".yellow
        else
          scheme_13_offences = Offence.joins(:fee_schemes).merge(FeeScheme.thirteen).merge(FeeScheme.lgfs).distinct
          before_count = scheme_13_offences.count
          puts "Deleted #{before_count} scheme 13 offences".green if scheme_13_offences.destroy_all
          puts "Reset offence pk sequence to #{Offence.ids.max}".green if set_offence_pk_sequence(Offence.ids.max)
        end
      end

      def remove_lgfs_scheme_thirteen_fee_type_roles
        scheme_9_fee_types_with_scheme_13_role = Fee::BaseFeeType.lgfs_scheme_9s.select { |ft| ft.roles.include?('lgfs_scheme_13') }

        if pretending?
          puts "Would remove lgfs_scheme_13 role from #{scheme_9_fee_types_with_scheme_13_role.count} fee_types".yellow
        else
          ActiveRecord::Base.transaction do
            scheme_9_fee_types_with_scheme_13_role.each do |ft|
              ft.roles.delete('lgfs_scheme_13')
              ft.save!
            end
          end
          puts "Removed lgfs scheme 13 role from #{scheme_9_fee_types_with_scheme_13_role.count} fee_types".green
        end
      end

      def destroy_lgfs_scheme_thirteen
        if pretending?
          puts "Would delete fee scheme 13: #{lgfs_fee_scheme_13&.attributes || 'does not exist'}".yellow
          puts "Would reset fee_schemes PK sequence to max id value".yellow
        else
          puts 'Deleted fee scheme 13'.green if lgfs_fee_scheme_13&.destroy
          puts "Reset fee_schemes pk sequence to #{FeeScheme.ids.max}".green \
            if ActiveRecord::Base.connection.set_pk_sequence!('fee_schemes', FeeScheme.ids.max)
        end
      end

      def rollback_scheme_nine
        print "Finding LGFS scheme 9".yellow
        lgfs_fee_scheme_nine = FeeScheme.find_by(name: 'LGFS', version: 9)
        lgfs_fee_scheme_nine ? print("...found\n".green) : print("...not found\n".red)

        print "Updating LGFS scheme 9 end date to nil".yellow
        print "...not updated\n".green if pretending?
        return if pretending?

        lgfs_fee_scheme_nine.update(end_date: nil)
        print "...updated\n".green
      end

      def create_or_update_lgfs_scheme_nine
        print "Finding LGFS scheme 9".yellow
        lgfs_fee_scheme_nine = FeeScheme.find_by(name: 'LGFS', version: 9)
        lgfs_fee_scheme_nine ? print("...found\n".green) : print("...not found\n".red)

        print "Updating LGFS scheme 9 end date to #{Settings.clair_release_date.end_of_day-1.day}".yellow
        print "...not updated\n".green if pretending?
        return if pretending?

        lgfs_fee_scheme_nine.update(end_date: Settings.clair_release_date.end_of_day-1.day)
        print "...updated\n".green
      end

      def create_lgfs_scheme_thirteen
        print "Finding or creating scheme 13 with start date #{Settings.clair_release_date.beginning_of_day}...".yellow
        print "...not created\n".green if pretending?
        return if pretending?

        FeeScheme.find_or_create_by(name: 'LGFS', version: 13, start_date: Settings.clair_release_date.beginning_of_day)
        print "...created\n".green
      end

      def create_lgfs_scheme_thirteen_offences
        puts "Scheme 13 offence count before: #{scheme_13_offence_count}".yellow
        copy_scheme_9_offences
        puts "Scheme 13 offence count after: #{scheme_13_offence_count}".yellow
      end

      def create_lgfs_scheme_thirteen_fee_types
        puts "Scheme 13 fee type count before: #{scheme_13_fee_type_count}".yellow
        require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: pretending?, stdout: false).call
        puts "Scheme 13 fee type count after: #{scheme_13_fee_type_count}".yellow
      end

      def scheme_13_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.thirteen).merge(FeeScheme.lgfs).distinct.count
      end

      def scheme_13_fee_type_count
        Fee::BaseFeeType.lgfs_scheme_13s.count
      end

      def copy_scheme_9_offences
        set_offence_pk_sequence(7000)
        puts 'Adding scheme 9 offences'.yellow

        Offence.transaction do
          lgfs_scheme_nine_offences.each do |offence|
            if pretending?
              puts "[WOULD-COPY] " + "#{offence.unique_code} => #{offence.unique_code}~13".yellow
            else
              new_offence = offence.dup
              new_offence.unique_code += '~13'
              new_offence.fee_schemes << lgfs_fee_scheme_13
              new_offence.save!
              print '.'.green
            end
          end
        end

        print "\n"
      end

      def set_offence_pk_sequence(sequence_start)
        if pretending?
          print "Resetting offences sequence to max offence id unless Offence.ids.max > sequence_start (#{Offence.ids.max} > #{sequence_start})...".yellow
          puts 'not resetting'.green
          return
        end
        raise StandardError, "Sequence cannot be set to value less than greatest id in use - #{Offence.ids.max} > #{sequence_start}" if Offence.ids.max > sequence_start
        ActiveRecord::Base.connection.set_pk_sequence!('offences', sequence_start)
      end

      def lgfs_scheme_nine_offences
        Offence.unscoped.
          joins(:fee_schemes).
          merge(FeeScheme.nine).
          merge(FeeScheme.lgfs).
          order(:id).
          distinct
      end
    end
  end
end
