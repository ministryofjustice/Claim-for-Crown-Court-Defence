# Class to:
# 1. create agfs fee scheme 13
# 2. add an end date to fee scheme 12 (day before scheme 13 start)
# 3. copy all fee scheme 12 offences, creating as fee scheme 13 records
# 4. create offence fee scheme through table records to assoicate each
#    with an fee scheme.
#
module Seeds
  module Schemas
    class AddAGFSFeeScheme13
      attr_reader :pretend
      alias_method :pretending?, :pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
         <<~STATUS
          \sAGFS scheme 12 end date: #{agfs_fee_scheme_12&.end_date || 'nil'}
          \sAGFS scheme 13 start date: #{agfs_fee_scheme_13&.start_date || 'nil'}
          \sAGFS scheme 13 fee scheme: #{agfs_fee_scheme_13&.attributes || 'nil'}
          \sAGFS scheme 13 offence count: #{scheme_13_offence_count}
          \sAGFS scheme 13 total fee_type count: #{scheme_13_fee_type_count}
          \s------------------------------------------------------------
          Status: #{agfs_fee_scheme_13.present? && scheme_13_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        create_or_update_agfs_scheme_twelve
        create_agfs_scheme_thirteen
        create_agfs_scheme_thirteen_offences
        create_scheme_thirteen_fee_types
      end

      def down
        destroy_agfs_scheme_13_offences
        remove_scheme_13_fee_type_roles
        destroy_scheme_13_update_12
      end

      private

      def agfs_fee_scheme_13
        @agfs_fee_scheme_13 ||= FeeScheme.agfs.thirteen.first
      end

      def agfs_fee_scheme_12
        @agfs_fee_scheme_12 ||= FeeScheme.agfs.twelve.first
      end

      def destroy_agfs_scheme_13_offences
        if pretending?
          puts "Would delete #{scheme_13_offence_count} scheme 13 offences".yellow
          puts "Would reset offence PK sequence to max id value: #{Offence.ids.max}".yellow
        else
          scheme_13_offences = Offence.joins(:fee_schemes).merge(FeeScheme.thirteen).merge(FeeScheme.agfs).distinct
          before_count = scheme_13_offences.count
          puts "Deleted #{before_count} scheme 13 offences".green if scheme_13_offences.destroy_all
          puts "Reset offence pk sequence to #{Offence.ids.max}".green if set_offence_pk_sequence(Offence.ids.max)
        end
      end

      def remove_scheme_13_fee_type_roles
        scheme_12_fee_types_with_scheme_13_role = Fee::BaseFeeType.agfs_scheme_12s.select { |ft| ft.roles.include?('agfs_scheme_13') }

        if pretending?
          puts "Would remove agfs_scheme_13 role from #{scheme_12_fee_types_with_scheme_13_role.count} fee_types".yellow
        else
          ActiveRecord::Base.transaction do
            scheme_12_fee_types_with_scheme_13_role.each do |ft|
              ft.roles.delete('agfs_scheme_13')
              ft.save!
            end
          end
          puts "Removed agfs scheme 13 role from #{scheme_12_fee_types_with_scheme_13_role.count} fee_types".green
        end
      end

      def destroy_scheme_13_update_12
        if pretending?
          puts "Would delete fee scheme 13: #{agfs_fee_scheme_13&.attributes || 'does not exist'}".yellow
          puts "Would update #{agfs_fee_scheme_12.attributes} end date to nil".yellow
          puts "Would reset fee_schemes PK sequence to max id value".yellow
        else
          puts 'Deleted fee scheme 13'.green if agfs_fee_scheme_13&.destroy
          puts 'Updated fee scheme 12 end date to nil'.green if agfs_fee_scheme_12&.update(end_date: nil)
          puts "Reset fee_schemes pk sequence to #{FeeScheme.ids.max}".green \
            if ActiveRecord::Base.connection.set_pk_sequence!('fee_schemes', FeeScheme.ids.max)
        end
      end

      def create_or_update_agfs_scheme_twelve
        print "Finding AGFS scheme 12".yellow
        agfs_fee_scheme_twelve = FeeScheme.find_by(name: 'AGFS', version: 12, start_date: Settings.clar_release_date.beginning_of_day)
        agfs_fee_scheme_twelve ? print("...found\n".green) : print("...not found\n".red)

        print "Updating AGFS scheme 12 end date to #{Settings.agfs_scheme_13_clair_release_date.end_of_day-1.day}".yellow
        print "...not updated\n".green if pretending?
        return if pretending?

        agfs_fee_scheme_twelve.update(end_date: Settings.agfs_scheme_13_clair_release_date.end_of_day-1.day)
        print "...updated\n".green
      end

      def create_agfs_scheme_thirteen
        print "Finding or creating scheme 13 with start date #{Settings.agfs_scheme_13_clair_release_date.beginning_of_day}...".yellow
        print "...not created\n".green if pretending?
        return if pretending?

        FeeScheme.find_or_create_by(name: 'AGFS', version: 13, start_date: Settings.agfs_scheme_13_clair_release_date.beginning_of_day)
        print "...created\n".green
      end

      def create_agfs_scheme_thirteen_offences
        puts "Scheme 13 offence count before: #{scheme_13_offence_count}".yellow
        copy_scheme_12_offences
        puts "Scheme 13 offence count after: #{scheme_13_offence_count}".yellow
      end

      def create_scheme_thirteen_fee_types
        puts "Scheme 13 fee type count before: #{scheme_13_fee_type_count}".yellow
        require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: pretending?, stdout: false).call
        puts "Scheme 13 fee type count after: #{scheme_13_fee_type_count}".yellow
      end

      def scheme_13_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.thirteen).merge(FeeScheme.agfs).distinct.count
      end

      def scheme_13_fee_type_count
        Fee::BaseFeeType.agfs_scheme_13s.count
      end

      def copy_scheme_12_offences
        set_offence_pk_sequence(10000)
        puts 'Adding scheme 13 offences'.yellow

        Offence.transaction do
          agfs_scheme_twelve_offences.each do |offence|
            if pretending?
              puts "[WOULD-COPY] " + "#{offence.unique_code} => #{offence.unique_code.sub('~12','~13')}".yellow
            else
              new_offence = offence.dup
              new_offence.unique_code = new_offence.unique_code.sub('~12','~13')
              new_offence.fee_schemes << agfs_fee_scheme_13
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

      def agfs_scheme_twelve_offences
        Offence.unscoped.
          joins(:fee_schemes).
          merge(FeeScheme.twelve).
          merge(FeeScheme.agfs).
          order(:id).
          distinct
      end
    end
  end
end
