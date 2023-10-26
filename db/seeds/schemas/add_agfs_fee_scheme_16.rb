module Seeds
  module Schemas
    class AddAGFSFeeScheme16
      attr_reader :pretend
      alias_method :pretending?, :pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
        <<~STATUS
          \sAGFS scheme 15 end date: #{agfs_fee_scheme_15&.end_date || 'nil'}
          \sAGFS scheme 16 start date: #{agfs_fee_scheme_16&.start_date || 'nil'}
          \sAGFS scheme 16 fee scheme: #{agfs_fee_scheme_16&.attributes || 'nil'}
          \sAGFS scheme 16 offence count: #{scheme_16_offence_count}
          \sAGFS scheme 16 total fee_type count: #{scheme_16_fee_type_count}
          \s------------------------------------------------------------
          Status: #{agfs_fee_scheme_16.present? && scheme_16_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        create_agfs_scheme_sixteen
        set_agfs_scheme_sixteen_offences
        create_scheme_sixteen_fee_types
      end

      def down
        unset_agfs_scheme_sixteen_offences
        remove_scheme_sixteen_fee_type_roles
        destroy_agfs_scheme_sixteen
      end

      private

      def agfs_fee_scheme_15
        @agfs_fee_scheme_15 ||= FeeScheme.agfs.version(15).first
      end

      def agfs_fee_scheme_16
        @agfs_fee_scheme_16 ||= FeeScheme.agfs.version(16).first
      end

      def scheme_16_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.version(16)).merge(FeeScheme.agfs).distinct.count
      end

      def scheme_16_fee_type_count
        Fee::BaseFeeType.agfs_scheme_16s.count
      end

      def create_agfs_scheme_sixteen
        print "Finding AGFS scheme 15".yellow
        agfs_fee_scheme_fifteen = FeeScheme.find_by(name: 'AGFS', version: 15, start_date: Settings.agfs_scheme_15_additional_prep_fee_and_kc.beginning_of_day)
        agfs_fee_scheme_fifteen ? print("...found\n".green) : print("...not found\n".red)

        print "Updating AGFS scheme 15 end date to #{Settings.agfs_scheme_16_section_twenty_eight_increase.end_of_day-1.day}".yellow
        if pretending?
          print "...not updated\n".green if pretending?
        else
          agfs_fee_scheme_fifteen.update(end_date: Settings.agfs_scheme_16_section_twenty_eight_increase.end_of_day-1.day)
          print "...updated\n".green
        end

        print "Finding or creating scheme 16 with start date #{Settings.agfs_scheme_16_section_twenty_eight_increase.beginning_of_day}...".yellow
        if pretending?
          print "...not created\n".green if pretending?
        else
          FeeScheme.find_or_create_by(name: 'AGFS', version: 16, start_date: Settings.agfs_scheme_16_section_twenty_eight_increase.beginning_of_day)
          print "...created\n".green
        end
      end

      def destroy_agfs_scheme_sixteen
        if pretending?
          puts "Would delete fee scheme 16: #{agfs_fee_scheme_16&.attributes || 'does not exist'}".yellow
          puts "Would update #{agfs_fee_scheme_15.attributes} end date to nil".yellow
        else
          puts 'Deleted fee scheme 16'.red if agfs_fee_scheme_16&.destroy
          puts 'Updated fee scheme 15 end date to nil'.green if agfs_fee_scheme_15&.update(end_date: nil)
        end
      end

      def set_agfs_scheme_sixteen_offences
        puts 'Setting scheme 15 offences to include scheme 16'.yellow
        puts "Scheme 16 offence count before: #{scheme_16_offence_count}".yellow
        Offence.transaction do
          agfs_scheme_fifteen_offences.each do |offence|
            if pretending?
              puts "[WOULD-ADD] Fee Scheme 16 to #{offence.unique_code}".yellow
            else
              next if offence.fee_schemes.include? agfs_fee_scheme_16

              offence.fee_schemes << agfs_fee_scheme_16
              print '.'.green
            end
          end
        end
        print "\n"
        puts "Scheme 16 offence count after: #{scheme_16_offence_count}".yellow
      end

      def unset_agfs_scheme_sixteen_offences
        Offence.transaction do
          Offence.joins(:fee_schemes).merge(FeeScheme.version(16)).merge(FeeScheme.agfs).distinct.each do |offence|
            if pretending?
              puts "[WOULD-REMOVE] Fee Scheme 16 from #{offence.unique_code}".yellow
            else
              offence.fee_schemes.delete(agfs_fee_scheme_16)
              print '.'.green
            end
          end
        end
        print "\n"
        puts "Scheme 16 offence count after: #{scheme_16_offence_count}".yellow
      end

      def agfs_scheme_fifteen_offences
        Offence.unscoped.
          joins(:fee_schemes).
          merge(FeeScheme.version(15)).
          merge(FeeScheme.agfs).
          order(:id).
          distinct
      end

      def create_scheme_sixteen_fee_types
        puts "Scheme 16 fee type count before: #{scheme_16_fee_type_count}".yellow
        require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: pretending?, stdout: false).call
        puts "Scheme 16 fee type count after: #{scheme_16_fee_type_count}".yellow
      end

      def remove_scheme_sixteen_fee_type_roles
        fee_types_with_scheme_16_role = Fee::BaseFeeType.agfs_scheme_16s

        if pretending?
          puts "Would remove agfs_scheme_16 role from #{fee_types_with_scheme_16_role.count} fee_types".yellow
        else
          ActiveRecord::Base.transaction do
            fee_types_with_scheme_16_role.each do |ft|
              if ft.roles == ['agfs_scheme_16']
                puts "Deleting fee type #{ft.description}".red
                ft.delete
              else
                puts "Removing agfs_scheme_16 role from #{ft.description}".green
                ft.roles.delete('agfs_scheme_16')
                ft.save!
              end
            end
          end
          puts "Fee types with scheme 16 role after: #{fee_types_with_scheme_16_role.count}".green
        end
      end
    end
  end
end
