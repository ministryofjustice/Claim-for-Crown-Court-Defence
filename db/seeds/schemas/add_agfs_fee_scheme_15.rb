module Seeds
  module Schemas
    class AddAgfsFeeScheme15
      attr_reader :pretend
      alias_method :pretending?, :pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
        <<~STATUS
          \sAGFS scheme 14 end date: #{agfs_fee_scheme_14&.end_date || 'nil'}
          \sAGFS scheme 15 start date: #{agfs_fee_scheme_15&.start_date || 'nil'}
          \sAGFS scheme 15 fee scheme: #{agfs_fee_scheme_15&.attributes || 'nil'}
          \sAGFS scheme 15 offence count: #{scheme_15_offence_count}
          \sAGFS scheme 15 total fee_type count: #{scheme_15_fee_type_count}
          \s------------------------------------------------------------
          Status: #{agfs_fee_scheme_15.present? && scheme_15_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        create_agfs_scheme_fifteen
        set_agfs_scheme_fifteen_offences
        create_scheme_fifteen_fee_types
      end

      def down
        unset_agfs_scheme_fifteen_offences
        remove_scheme_fifteen_fee_type_roles
        destroy_agfs_scheme_fifteen
      end

      private

      def agfs_fee_scheme_14
        @agfs_fee_scheme_14 ||= FeeScheme.agfs.version(14).first
      end

      def agfs_fee_scheme_15
        @agfs_fee_scheme_15 ||= FeeScheme.agfs.version(15).first
      end

      def scheme_15_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.version(15)).merge(FeeScheme.agfs).distinct.count
      end

      def scheme_15_fee_type_count
        Fee::BaseFeeType.agfs_scheme_15s.count
      end

      def create_agfs_scheme_fifteen
        print "Finding AGFS scheme 14".yellow
        agfs_fee_scheme_fourteen = FeeScheme.find_by(name: 'AGFS', version: 14, start_date: Settings.agfs_scheme_14_section_twenty_eight.beginning_of_day)
        agfs_fee_scheme_fourteen ? print("...found\n".green) : print("...not found\n".red)

        print "Updating AGFS scheme 14 end date to #{Settings.agfs_scheme_15_additional_prep_fee_and_kc.end_of_day-1.day}".yellow
        if pretending?
          print "...not updated\n".green if pretending?
        else
          agfs_fee_scheme_fourteen.update(end_date: Settings.agfs_scheme_15_additional_prep_fee_and_kc.end_of_day-1.day)
          print "...updated\n".green
        end

        print "Finding or creating scheme 15 with start date #{Settings.agfs_scheme_15_additional_prep_fee_and_kc.beginning_of_day}...".yellow
        if pretending?
          print "...not created\n".green if pretending?
        else
          FeeScheme.find_or_create_by(name: 'AGFS', version: 15, start_date: Settings.agfs_scheme_15_additional_prep_fee_and_kc.beginning_of_day)
          print "...created\n".green
        end
      end

      def destroy_agfs_scheme_fifteen
        if pretending?
          puts "Would delete fee scheme 15: #{agfs_fee_scheme_15&.attributes || 'does not exist'}".yellow
          puts "Would update #{agfs_fee_scheme_14.attributes} end date to nil".yellow
        else
          puts 'Deleted fee scheme 15'.red if agfs_fee_scheme_15&.destroy
          puts 'Updated fee scheme 14 end date to nil'.green if agfs_fee_scheme_14&.update(end_date: nil)
        end
      end

      def set_agfs_scheme_fifteen_offences
        puts 'Setting scheme 11 offences to include scheme 15'.yellow
        Offence.transaction do
          agfs_scheme_eleven_offences.each do |offence|
            if pretending?
              puts "[WOULD-ADD] Fee Scheme 15 to #{offence.unique_code}".yellow
            else
              offence.fee_schemes << agfs_fee_scheme_15
              print '.'.green
            end
          end
        end
        print "\n"
      end

      def unset_agfs_scheme_fifteen_offences
        Offence.transaction do
          Offence.joins(:fee_schemes).merge(FeeScheme.version(15)).merge(FeeScheme.agfs).distinct.each do |offence|
            if pretending?
              puts "[WOULD-REMOVE] Fee Scheme 15 from #{offence.unique_code}".yellow
            else
              offence.fee_schemes.delete(agfs_fee_scheme_15)
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

      def create_scheme_fifteen_fee_types
        puts "Scheme 15 fee type count before: #{scheme_15_fee_type_count}".yellow
        require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: pretending?, stdout: false).call
        puts "Scheme 15 fee type count after: #{scheme_15_fee_type_count}".yellow
      end

      def remove_scheme_fifteen_fee_type_roles
        fee_types_with_scheme_15_role = Fee::BaseFeeType.agfs_scheme_15s

        if pretending?
          puts "Would remove agfs_scheme_15 role from #{fee_types_with_scheme_15_role.count} fee_types".yellow
        else
          ActiveRecord::Base.transaction do
            fee_types_with_scheme_15_role.each do |ft|
              if ft.roles == ['agfs_scheme_15']
                puts "Deleting fee type #{ft.description}".red
                ft.delete
              else
                puts "Removing agfs_scheme_15 role from #{ft.description}".green
                ft.roles.delete('agfs_scheme_15')
                ft.save!
              end
            end
          end
          puts "Fee types with scheme 15 role after: #{fee_types_with_scheme_15_role.count}".green
        end
      end
    end
  end
end
