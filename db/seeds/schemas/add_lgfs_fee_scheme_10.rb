# Class to:
# 1. create lgfs fee scheme 10
# 2. add an end date to fee scheme 9 (day before scheme 10 start)
# 3. copy all fee scheme 9 offences, creating as fee scheme 10 records
# 4. create offence fee scheme through table records to associate each
#    with an fee scheme.
#
module Seeds
  module Schemas
    class AddLgfsFeeScheme10
      attr_reader :pretend
      alias_method :pretending?, :pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
         <<~STATUS
          \sLGFS scheme 9 start date: #{lgfs_fee_scheme_9&.start_date || 'nil'}
          \sLGFS scheme 9 end date: #{lgfs_fee_scheme_9&.end_date || 'nil'}
          \sLGFS scheme 10 start date: #{lgfs_fee_scheme_10&.start_date || 'nil'}
          \sLGFS scheme 10 fee scheme: #{lgfs_fee_scheme_10&.attributes || 'nil'}
          \sLGFS scheme 10 offence count: #{scheme_10_offence_count}
          \sLGFS scheme 10 total fee_type count: #{scheme_10_fee_type_count}
          \s------------------------------------------------------------
          Status: #{lgfs_fee_scheme_10.present? && scheme_10_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        create_or_update_lgfs_scheme_nine
        create_lgfs_scheme_ten
        create_lgfs_scheme_ten_offences
        create_lgfs_scheme_ten_fee_types
      end

      def down
        destroy_lgfs_scheme_ten_offences
        remove_lgfs_scheme_ten_fee_type_roles
        destroy_lgfs_scheme_ten
        rollback_scheme_nine
      end

      private

      def lgfs_fee_scheme_10
        @lgfs_fee_scheme_10 ||= FeeScheme.lgfs.ten.first
      end

      def lgfs_fee_scheme_9
        @lgfs_fee_scheme_9 ||= FeeScheme.lgfs.nine.first
      end

      def destroy_lgfs_scheme_ten_offences
        if pretending?
          puts "Would delete #{scheme_10_offence_count} LGFS fee scheme 10 offences".yellow
          puts "Would reset offence PK sequence to max id value: #{Offence.ids.max}".yellow
        else
          scheme_10_offences = Offence.joins(:fee_schemes).merge(FeeScheme.ten).merge(FeeScheme.lgfs).distinct
          before_count = scheme_10_offences.count
          puts "Deleted #{before_count} LGFS fee scheme 10 offences".green if scheme_10_offences.destroy_all
          puts "Reset offence pk sequence to #{Offence.ids.max}".green if set_offence_pk_sequence(Offence.ids.max)
        end
      end

      def remove_lgfs_scheme_ten_fee_type_roles
        scheme_9_fee_types_with_scheme_10_role = Fee::BaseFeeType.lgfs_scheme_9s.select { |ft| ft.roles.include?('lgfs_scheme_10') }

        if pretending?
          puts "Would remove lgfs_scheme_10 role from #{scheme_9_fee_types_with_scheme_10_role.count} fee_types".yellow
        else
          ActiveRecord::Base.transaction do
            scheme_9_fee_types_with_scheme_10_role.each do |ft|
              ft.roles.delete('lgfs_scheme_10')
              ft.save!
            end
          end
          puts "Removed lgfs scheme 10 role from #{scheme_9_fee_types_with_scheme_10_role.count} fee_types".green
        end
      end

      def destroy_lgfs_scheme_ten
        if pretending?
          puts "Would delete LGFS fee scheme 10: #{lgfs_fee_scheme_10&.attributes || 'does not exist'}".yellow
          puts "Would reset fee_schemes PK sequence to max id value".yellow
        else
          puts 'Deleted LGFS fee scheme 10'.green if lgfs_fee_scheme_10&.destroy
          puts "Reset fee_schemes pk sequence to #{FeeScheme.ids.max}".green \
            if ActiveRecord::Base.connection.set_pk_sequence!('fee_schemes', FeeScheme.ids.max)
        end
      end

      def rollback_scheme_nine
        print "Finding LGFS fee scheme 9".yellow
        lgfs_fee_scheme_nine = FeeScheme.find_by(name: 'LGFS', version: 9)
        lgfs_fee_scheme_nine ? print("...found\n".green) : print("...not found\n".red)

        print "Updating LGFS fee scheme 9 end date to nil".yellow
        print "...not updated\n".green if pretending?
        return if pretending?

        lgfs_fee_scheme_nine.update(end_date: nil)
        print "...updated\n".green
      end

      def create_or_update_lgfs_scheme_nine
        print "Finding LGFS fee scheme 9".yellow
        lgfs_fee_scheme_nine = FeeScheme.find_by(name: 'LGFS', version: 9)
        lgfs_fee_scheme_nine ? print("...found\n".green) : print("...not found\n".red)

        print "Updating LGFS fee scheme 9 end date to #{Settings.lgfs_scheme_10_clair_release_date.end_of_day-1.day}".yellow
        print "...not updated\n".green if pretending?
        return if pretending?

        lgfs_fee_scheme_nine.update(end_date: Settings.lgfs_scheme_10_clair_release_date.end_of_day-1.day)
        print "...updated\n".green
      end

      def create_lgfs_scheme_ten
        print "Finding or creating LGFS fee scheme 10 with start date #{Settings.lgfs_scheme_10_clair_release_date.beginning_of_day}...".yellow
        print "...not created\n".green if pretending?
        return if pretending?

        FeeScheme.find_or_create_by(name: 'LGFS', version: 10, start_date: Settings.lgfs_scheme_10_clair_release_date.beginning_of_day)
        print "...created\n".green
      end

      def create_lgfs_scheme_ten_offences
        puts "LGFS fee scheme 10 offence count before: #{scheme_10_offence_count}".yellow
        copy_scheme_9_offences
        puts "LGFS fee scheme 10 offence count after: #{scheme_10_offence_count}".yellow
      end

      def create_lgfs_scheme_ten_fee_types
        puts "LGFS fee scheme 10 fee type count before: #{scheme_10_fee_type_count}".yellow
        require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: pretending?, stdout: false).call
        puts "LGFS fee scheme 10 fee type count after: #{scheme_10_fee_type_count}".yellow
      end

      def scheme_10_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.ten).merge(FeeScheme.lgfs).distinct.count
      end

      def scheme_10_fee_type_count
        Fee::BaseFeeType.lgfs_scheme_10s.count
      end

      def copy_scheme_9_offences
        set_offence_pk_sequence(8000)
        puts 'Adding LGFS fee scheme 10 offences'.yellow

        Offence.transaction do
          lgfs_scheme_nine_offences.each do |offence|
            if pretending?
              puts "[WOULD-COPY] " + "#{offence.unique_code} => #{offence.unique_code}~10".yellow
            else
              new_offence = offence.dup
              new_offence.unique_code += '~10'
              new_offence.fee_schemes << lgfs_fee_scheme_10
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
