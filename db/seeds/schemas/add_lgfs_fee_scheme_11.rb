# Class to:
# 1. create lgfs fee scheme 11
# 2. add an end date to fee scheme 10 (day before scheme 11 start)
# 3. copy all fee scheme 10 offences, creating as fee scheme 11 records
# 4. create offence fee scheme through table records to associate each
#    with an fee scheme.
#
module Seeds
  module Schemas
    class AddLGFSFeeScheme11
      attr_reader :pretend
      alias_method :pretending?, :pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
         <<~STATUS
          \sLGFS scheme 10 start date: #{lgfs_fee_scheme_10&.start_date || 'nil'}
          \sLGFS scheme 10 end date: #{lgfs_fee_scheme_10&.end_date || 'nil'}
          \sLGFS scheme 11 start date: #{lgfs_fee_scheme_11&.start_date || 'nil'}
          \sLGFS scheme 11 fee scheme: #{lgfs_fee_scheme_11&.attributes || 'nil'}
          \sLGFS scheme 11 offence count: #{lgfs_scheme_11_offence_count}
          \sLGFS scheme 11 total fee_type count: #{lgfs_scheme_11_fee_type_count}
          \s------------------------------------------------------------
          Status: #{lgfs_fee_scheme_11.present? && lgfs_scheme_11_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        update_lgfs_scheme_ten
        create_lgfs_scheme_eleven
        set_lgfs_scheme_eleven_offences
        create_lgfs_scheme_eleven_fee_types
      end

      def down
        unset_lgfs_scheme_eleven_offences
        remove_lgfs_scheme_eleven_fee_type_roles
        destroy_lgfs_scheme_eleven
        rollback_lgfs_scheme_ten
      end

      private

      def lgfs_fee_scheme_11
        @lgfs_fee_scheme_11 ||= FeeScheme.lgfs.eleven.first
      end

      def lgfs_fee_scheme_10
        @lgfs_fee_scheme_10 ||= FeeScheme.lgfs.ten.first
      end

      def unset_lgfs_scheme_eleven_offences
        Offence.transaction do
          Offence.joins(:fee_schemes).merge(FeeScheme.version(11)).merge(FeeScheme.lgfs).distinct.each do |offence|
            if pretending?
              puts "[WOULD-REMOVE] Fee Scheme 11 from #{offence.unique_code}".yellow
            else
              offence.fee_schemes.delete(lgfs_fee_scheme_11)
              print '.'.green
            end
          end
        end
        print "\n"
        puts "LGFS Scheme 11 offence count after: #{lgfs_scheme_11_offence_count}".yellow
      end

      def remove_lgfs_scheme_eleven_fee_type_roles
        lgfs_scheme_10_fee_types_with_lgfs_scheme_11_role = Fee::BaseFeeType.lgfs_scheme_10s.select { |ft| ft.roles.include?('lgfs_scheme_11') }

        if pretending?
          puts "Would remove lgfs_scheme_11 role from #{lgfs_scheme_10_fee_types_with_lgfs_scheme_11_role.count} fee_types".yellow
        else
          ActiveRecord::Base.transaction do
            lgfs_scheme_10_fee_types_with_lgfs_scheme_11_role.each do |ft|
              ft.roles.delete('lgfs_scheme_11')
              ft.save!
            end
          end
          puts "Removed lgfs scheme 11 role from #{lgfs_scheme_10_fee_types_with_lgfs_scheme_11_role.count} fee_types".green
        end
      end

      def destroy_lgfs_scheme_eleven
        if pretending?
          puts "Would delete LGFS fee scheme 11: #{lgfs_fee_scheme_11&.attributes || 'does not exist'}".yellow
          puts "Would reset fee_schemes PK sequence to max id value".yellow
        else
          puts 'Deleted LGFS fee scheme 11'.green if lgfs_fee_scheme_11&.destroy
          puts "Reset fee_schemes pk sequence to #{FeeScheme.ids.max}".green \
            if ActiveRecord::Base.connection.set_pk_sequence!('fee_schemes', FeeScheme.ids.max)
        end
      end

      def rollback_lgfs_scheme_ten
        print "Finding LGFS fee scheme 10".yellow
        lgfs_fee_scheme_ten = FeeScheme.find_by(name: 'LGFS', version: 10)
        lgfs_fee_scheme_ten ? print("...found\n".green) : print("...not found\n".red)

        print "Updating LGFS fee scheme 10 end date to nil".yellow
        print "...not updated\n".green if pretending?
        return if pretending?

        lgfs_fee_scheme_ten.update(end_date: nil)
        print "...updated\n".green
      end

      def update_lgfs_scheme_ten
        print "Finding LGFS fee scheme 10".yellow
        lgfs_fee_scheme_ten = FeeScheme.find_by(name: 'LGFS', version: 10)
        lgfs_fee_scheme_ten ? print("...found\n".green) : print("...not found\n".red)

        print "Updating LGFS fee scheme 10 end date to #{Settings.lgfs_scheme_11_release_date.end_of_day-1.day}".yellow
        print "...not updated\n".green if pretending?
        return if pretending?

        lgfs_fee_scheme_ten.update(end_date: Settings.lgfs_scheme_11_release_date.end_of_day-1.day)
        print "...updated\n".green
      end

      def create_lgfs_scheme_eleven
        print "Finding or creating LGFS fee scheme 11 with start date #{Settings.lgfs_scheme_11_release_date.beginning_of_day}...".yellow
        print "...not created\n".green if pretending?
        return if pretending?

        FeeScheme.find_or_create_by(name: 'LGFS', version: 11, start_date: Settings.lgfs_scheme_11_release_date.beginning_of_day)
        print "...created\n".green
      end

      def set_lgfs_scheme_eleven_offences
        puts 'Setting LGFS scheme 10 offences to include scheme 11'.yellow
        puts "LGFS Scheme 11 offence count before: #{lgfs_scheme_11_offence_count}".yellow
        Offence.transaction do
          lgfs_scheme_ten_offences.each do |offence|
            if pretending?
              puts "[WOULD-ADD] LGFS Fee Scheme 11 to #{offence.unique_code}".yellow
            else
              next if offence.fee_schemes.include? lgfs_fee_scheme_11

              offence.fee_schemes << lgfs_fee_scheme_11
              print '.'.green
            end
          end
        end
        print "\n"
        puts "LGFS Scheme 11 offence count after: #{lgfs_scheme_11_offence_count}".yellow
      end

      def create_lgfs_scheme_eleven_fee_types
        puts "LGFS fee scheme 11 fee type count before: #{lgfs_scheme_11_fee_type_count}".yellow
        require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: pretending?, stdout: false).call
        puts "LGFS fee scheme 11 fee type count after: #{lgfs_scheme_11_fee_type_count}".yellow
      end

      def lgfs_scheme_11_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.eleven).merge(FeeScheme.lgfs).distinct.count
      end

      def lgfs_scheme_11_fee_type_count
        Fee::BaseFeeType.lgfs_scheme_11s.count
      end

      def lgfs_scheme_ten_offences
        Offence.unscoped.
          joins(:fee_schemes).
          merge(FeeScheme.ten).
          merge(FeeScheme.lgfs).
          order(:id).
          distinct
      end
    end
  end
end
