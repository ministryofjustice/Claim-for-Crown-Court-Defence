# Class to:
# 1. create agfs fee scheme 12
# 2. add an end date to fee scheme 11 (day before scheme 12 start)
# 3. copy all fee scheme 11 offences, creating as fee scheme 12 records
# 4. create offence fee scheme through table records to assoicate each
#    with an fee scheme.
#
module Seeds
  module Schemas
    class AddAGFSFeeScheme12
      attr_reader :pretend
      alias_method :pretending?, :pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
         <<~STATUS
          \sAGFS scheme 11 end date: #{agfs_fee_scheme_11&.end_date || 'nil'}
          \sAGFS scheme 12 start date: #{agfs_fee_scheme_12&.start_date || 'nil'}
          \sAGFS scheme 12 fee scheme: #{agfs_fee_scheme_12&.attributes || 'nil'}
          \sAGFS scheme 12 offence count: #{scheme_12_offence_count}
          \sAGFS scheme 12 total fee_type count: #{scheme_12_fee_type_count}
          \sAGFS scheme 12 new fee_type count: #{scheme_12_only_fee_types.count}
          \s------------------------------------------------------------
          Status: #{agfs_fee_scheme_12.present? && scheme_12_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        create_or_update_agfs_scheme_eleven
        create_agfs_scheme_twelve
        create_agfs_scheme_twelve_offences
        create_scheme_twelve_fee_types
      end

      def down
        destroy_agfs_scheme_12_offences
        destroy_scheme_12_only_fee_types
        remove_scheme_12_fee_type_roles
        destroy_scheme_12_update_11
      end

      private

      def agfs_fee_scheme_12
        @agfs_fee_scheme_12 ||= FeeScheme.agfs.twelve.first
      end

      def agfs_fee_scheme_11
        @agfs_fee_scheme_11 ||= FeeScheme.agfs.eleven.first
      end

      def destroy_agfs_scheme_12_offences
        if pretending?
          puts "Would delete #{scheme_12_offence_count} scheme 12 offences".yellow
          puts "Would reset offence PK sequence to max id value: #{Offence.ids.max}".yellow
        else
          scheme_12_offences = Offence.joins(:fee_schemes).merge(FeeScheme.twelve).merge(FeeScheme.agfs).distinct
          before_count = scheme_12_offences.count
          puts "Deleted #{before_count} scheme 12 offences".green if scheme_12_offences.destroy_all
          puts "Reset offence pk sequence to #{Offence.ids.max}".green if set_offence_pk_sequence(Offence.ids.max)
        end
      end

      def destroy_scheme_12_only_fee_types
        if pretending?
          puts "Would delete scheme 12 fee types: #{scheme_12_only_fee_types.count} #{scheme_12_only_fee_types.pluck(:id, :description).join(', ') || 'none to delete'}".yellow
        else
          # do not apply callback dependency: :destroy
          scheme_12_only_fee_types.delete_all
          puts "Deleted #{scheme_12_only_fee_types.count} fee_types #{scheme_12_only_fee_types.map(&:description).join(', ')}".green
        end
      end

      def remove_scheme_12_fee_type_roles
        scheme_10_fee_types_with_scheme_12_role = Fee::BaseFeeType.agfs_scheme_10s.select { |ft| ft.roles.include?('agfs_scheme_12') }

        if pretending?
          puts "Would remove agfs_scheme_12 role from #{scheme_10_fee_types_with_scheme_12_role.count} fee_types".yellow
        else
          ActiveRecord::Base.transaction do
            scheme_10_fee_types_with_scheme_12_role.each do |ft|
              ft.roles.delete('agfs_scheme_12')
              ft.save!
            end
          end
          puts "Removed agfs scheme 12 role from #{scheme_10_fee_types_with_scheme_12_role.count} fee_types".green
        end
      end

      def destroy_scheme_12_update_11
        if pretending?
          puts "Would delete fee scheme 12: #{agfs_fee_scheme_12&.attributes || 'does not exist'}".yellow
          puts "Would update #{agfs_fee_scheme_11.attributes} end date to nil".yellow
          puts "Would reset fee_schemes PK sequence to max id value".yellow
        else
          puts 'Deleted fee scheme 12'.green if agfs_fee_scheme_12&.destroy
          puts 'Updated fee scheme 11 end date to nil'.green if agfs_fee_scheme_11&.update(end_date: nil)
          puts "Reset fee_schemes pk sequence to #{FeeScheme.ids.max}".green \
            if ActiveRecord::Base.connection.set_pk_sequence!('fee_schemes', FeeScheme.ids.max)
        end
      end

      def create_or_update_agfs_scheme_eleven
        print "Finding AGFS scheme 11".yellow
        agfs_fee_scheme_eleven = FeeScheme.find_by(name: 'AGFS', version: 11, start_date: Settings.agfs_scheme_11_release_date.beginning_of_day)
        agfs_fee_scheme_eleven ? print("...found\n".green) : print("...not found\n".red)

        print "Updating AGFS scheme 11 end date to #{Settings.clar_release_date.end_of_day-1.day}".yellow
        print "...not updated\n".green if pretending?
        return if pretending?

        agfs_fee_scheme_eleven.update(end_date: Settings.clar_release_date.end_of_day-1.day)
        print "...updated\n".green
      end

      def create_agfs_scheme_twelve
        print "Finding or creating scheme 12 with start date #{Settings.clar_release_date.beginning_of_day}...".yellow
        print "...not created\n".green if pretending?
        return if pretending?

        FeeScheme.find_or_create_by(name: 'AGFS', version: 12, start_date: Settings.clar_release_date.beginning_of_day)
        print "...created\n".green
      end

      def create_agfs_scheme_twelve_offences
        puts "Scheme 12 offence count before: #{scheme_12_offence_count}".yellow
        copy_scheme_11_offences
        puts "Scheme 12 offence count after: #{scheme_12_offence_count}".yellow
      end

      def create_scheme_twelve_fee_types
        puts "Scheme 12 fee type count before: #{scheme_12_fee_type_count}".yellow
        require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: pretending?, stdout: false).call
        puts "Scheme 12 fee type count after: #{scheme_12_fee_type_count}".yellow
      end

      def scheme_12_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.twelve).merge(FeeScheme.agfs).distinct.count
      end

      def scheme_12_fee_type_count
        Fee::BaseFeeType.agfs_scheme_12s.count
      end

      def scheme_12_only_fee_types
        Fee::BaseFeeType.where(unique_code: ['MIUMU', 'MIUMO', 'MIPHC'])
      end

      def copy_scheme_11_offences
        set_offence_pk_sequence(5000)
        puts 'Adding scheme 12 offences'.yellow

        Offence.transaction do
          agfs_scheme_eleven_offences.each do |offence|
            if pretending?
              puts "[WOULD-COPY] " + "#{offence.unique_code} => #{offence.unique_code.sub('~11','~12')}".yellow
            else
              new_offence = offence.dup
              new_offence.unique_code = new_offence.unique_code.sub('~11','~12')
              new_offence.fee_schemes << agfs_fee_scheme_12
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

      def agfs_scheme_eleven_offences
        Offence.unscoped.
          joins(:fee_schemes).
          merge(FeeScheme.eleven).
          merge(FeeScheme.agfs).
          order(:id).
          distinct
      end
    end
  end
end
