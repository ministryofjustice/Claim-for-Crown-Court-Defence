module Seeds
  module Schemas
    class AddAGFSFeeScheme14
      attr_reader :pretend
      alias_method :pretending?, :pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
        <<~STATUS
          \sAGFS scheme 13 end date: #{agfs_fee_scheme_13&.end_date || 'nil'}
          \sAGFS scheme 14 start date: #{agfs_fee_scheme_14&.start_date || 'nil'}
          \sAGFS scheme 14 fee scheme: #{agfs_fee_scheme_14&.attributes || 'nil'}
          \sAGFS scheme 14 offence count: #{scheme_14_offence_count}
          \sAGFS scheme 14 total fee_type count: #{scheme_14_fee_type_count}
          \s------------------------------------------------------------
          Status: #{agfs_fee_scheme_14.present? && scheme_14_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        create_agfs_scheme_fourteen
        set_agfs_scheme_fourteen_offences
        create_scheme_fourteen_fee_types
      end

      def down
        unset_agfs_scheme_fourteen_offences
        remove_scheme_fourteen_fee_type_roles
        destroy_agfs_scheme_fourteen
      end

      private

      def agfs_fee_scheme_14
        @agfs_fee_scheme_14 ||= FeeScheme.agfs.version(14).first
      end

      def agfs_fee_scheme_13
        @agfs_fee_scheme_13 ||= FeeScheme.agfs.thirteen.first
      end

      def scheme_14_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.version(14)).merge(FeeScheme.agfs).distinct.count
      end

      def scheme_14_fee_type_count
        Fee::BaseFeeType.agfs_scheme_14s.count
      end

      def create_agfs_scheme_fourteen
        print "Finding AGFS scheme 13".yellow
        agfs_fee_scheme_thirteen = FeeScheme.find_by(name: 'AGFS', version: 13, start_date: Settings.agfs_scheme_13_clair_release_date.beginning_of_day)
        agfs_fee_scheme_thirteen ? print("...found\n".green) : print("...not found\n".red)

        print "Updating AGFS scheme 13 end date to #{Settings.agfs_scheme_14_section_twenty_eight.end_of_day-1.day}".yellow
        if pretending?
          print "...not updated\n".green if pretending?
        else
          agfs_fee_scheme_thirteen.update(end_date: Settings.agfs_scheme_14_section_twenty_eight.end_of_day-1.day)
          print "...updated\n".green
        end

        print "Finding or creating scheme 14 with start date #{Settings.agfs_scheme_14_section_twenty_eight.beginning_of_day}...".yellow
        if pretending?
          print "...not created\n".green if pretending?
        else
          FeeScheme.find_or_create_by(name: 'AGFS', version: 14, start_date: Settings.agfs_scheme_14_section_twenty_eight.beginning_of_day)
          print "...created\n".green
        end
      end

      def destroy_agfs_scheme_fourteen
        if pretending?
          puts "Would delete fee scheme 14: #{agfs_fee_scheme_14&.attributes || 'does not exist'}".yellow
          puts "Would update #{agfs_fee_scheme_13.attributes} end date to nil".yellow
        else
          puts 'Deleted fee scheme 14'.red if agfs_fee_scheme_14&.destroy
          puts 'Updated fee scheme 13 end date to nil'.green if agfs_fee_scheme_13&.update(end_date: nil)
        end
      end

      def set_agfs_scheme_fourteen_offences
        puts 'Setting scheme 11 offences to include scheme 14'.yellow
        Offence.transaction do
          agfs_scheme_eleven_offences.each do |offence|
            if pretending?
              puts "[WOULD-ADD] Fee Scheme 14 to #{offence.unique_code}".yellow
            else
              offence.fee_schemes << agfs_fee_scheme_14
              print '.'.green
            end
          end
        end
        print "\n"
      end

      def unset_agfs_scheme_fourteen_offences
        Offence.transaction do
          Offence.joins(:fee_schemes).merge(FeeScheme.version(14)).merge(FeeScheme.agfs).distinct.each do |offence|
            if pretending?
              puts "[WOULD-REMOVE] Fee Scheme 14 from #{offence.unique_code}".yellow
            else
              offence.fee_schemes.delete(agfs_fee_scheme_14)
              print '.'.green
            end
          end
        end
        print "\n"
      end

      def agfs_scheme_eleven_offences
        Offence.unscoped.
          joins(:fee_schemes).
          merge(FeeScheme.eleven).
          merge(FeeScheme.agfs).
          order(:id).
          distinct
      end

      def create_scheme_fourteen_fee_types
        puts "Scheme 14 fee type count before: #{scheme_14_fee_type_count}".yellow
        require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: pretending?, stdout: false).call
        puts "Scheme 14 fee type count after: #{scheme_14_fee_type_count}".yellow
      end

      def remove_scheme_fourteen_fee_type_roles
        fee_types_with_scheme_14_role = Fee::BaseFeeType.agfs_scheme_14s

        if pretending?
          puts "Would remove agfs_scheme_14 role from #{fee_types_with_scheme_14_role.count} fee_types".yellow
        else
          ActiveRecord::Base.transaction do
            fee_types_with_scheme_14_role.each do |ft|
              if ft.roles == ['agfs_scheme_14']
                puts "Deleting fee type #{ft.description}".red
                ft.delete
              else
                puts "Removing agfs_scheme_14 role from #{ft.description}".green
                ft.roles.delete('agfs_scheme_14')
                ft.save!
              end
            end
          end
          puts "Removed agfs scheme 14 role from #{fee_types_with_scheme_14_role.count} fee_types".green
        end
      end
    end
  end
end
