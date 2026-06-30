module Seeds
  module Schemas
    class AddAGFSFeeScheme17
      attr_reader :pretend
      alias_method :pretending?, :pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
        <<~STATUS
          \sAGFS scheme 16 end date: #{agfs_fee_scheme_16&.end_date || 'nil'}
          \sAGFS scheme 17 start date: #{agfs_fee_scheme_17&.start_date || 'nil'}
          \sAGFS scheme 17 fee scheme: #{agfs_fee_scheme_17&.attributes || 'nil'}
          \sAGFS scheme 17 offence count: #{scheme_17_offence_count}
          \sAGFS scheme 17 total fee_type count: #{scheme_17_fee_type_count}
          \s------------------------------------------------------------
          Status: #{agfs_fee_scheme_17.present? && scheme_17_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        create_agfs_scheme_seventeen
        set_agfs_scheme_seventeen_offences
        create_scheme_seventeen_fee_types
      end

      def down
        remove_scheme_seventeen_fee_type_roles
        unset_agfs_scheme_seventeen_offences
        destroy_agfs_scheme_seventeen
      end

      private

      def agfs_fee_scheme_16
        @agfs_fee_scheme_16 ||= FeeScheme.agfs.version(16).first
      end

      def agfs_fee_scheme_17
        @agfs_fee_scheme_17 ||= FeeScheme.agfs.version(17).first
      end

      def scheme_17_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.version(17)).merge(FeeScheme.agfs).distinct.count
      end

      def scheme_17_fee_type_count
        Fee::BaseFeeType.agfs_scheme_17s.count
      end

      def create_agfs_scheme_seventeen
        print "Finding AGFS scheme 16".yellow
        agfs_fee_scheme_sixteen = FeeScheme.find_by(name: 'AGFS', version: 16, start_date: Settings.agfs_scheme_16_section_twenty_eight_increase.beginning_of_day)
        agfs_fee_scheme_sixteen ? print("...found\n".green) : print("...not found\n".red)

        print "Updating AGFS scheme 16 end date to #{Settings.agfs_scheme_17.end_of_day-1.day}".yellow
        if pretending?
          print "...not updated\n".green if pretending?
        else
          agfs_fee_scheme_sixteen.update(end_date: Settings.agfs_scheme_17.end_of_day-1.day)
          print "...updated\n".green
        end

        print "Finding or creating scheme 17 with start date #{Settings.agfs_scheme_17.beginning_of_day}...".yellow
        if pretending?
          print "...not created\n".green if pretending?
        else
          FeeScheme.find_or_create_by(name: 'AGFS', version: 17, start_date: Settings.agfs_scheme_17.beginning_of_day)
          print "...created\n".green
        end
      end

      def destroy_agfs_scheme_seventeen
        if pretending?
          puts "Would delete fee scheme 17: #{agfs_fee_scheme_17&.attributes || 'does not exist'}".yellow
          puts "Would update #{agfs_fee_scheme_16.attributes} end date to nil".yellow
        else
          puts 'Deleted fee scheme 17'.red if agfs_fee_scheme_17&.destroy
          puts 'Updated fee scheme 16 end date to nil'.green if agfs_fee_scheme_16&.update(end_date: nil)
        end
      end

      def set_agfs_scheme_seventeen_offences
        puts 'Setting scheme 16 offences to include scheme 17'.yellow
        puts "Scheme 17 offence count before: #{scheme_17_offence_count}".yellow
        Offence.transaction do
          agfs_scheme_sixteen_offences.each do |offence|
            if pretending?
              puts "[WOULD-ADD] Fee Scheme 17 to #{offence.unique_code}".yellow
            else
              next if offence.fee_schemes.include? agfs_fee_scheme_17

              offence.fee_schemes << agfs_fee_scheme_17
              print '.'.green
            end
          end
        end
        print "\n"
        puts "Scheme 17 offence count after: #{scheme_17_offence_count}".yellow
      end

      def unset_agfs_scheme_seventeen_offences
        Offence.transaction do
          Offence.joins(:fee_schemes).merge(FeeScheme.version(17)).merge(FeeScheme.agfs).distinct.each do |offence|
            if pretending?
              puts "[WOULD-REMOVE] Fee Scheme 17 from #{offence.unique_code}".yellow
            else
              offence.fee_schemes.delete(agfs_fee_scheme_17)
              print '.'.green
            end
          end
        end
        print "\n"
        puts "Scheme 17 offence count after: #{scheme_17_offence_count}".yellow
      end

      def agfs_scheme_sixteen_offences
        Offence.unscoped.
          joins(:fee_schemes).
          merge(FeeScheme.version(16)).
          merge(FeeScheme.agfs).
          order(:id).
          distinct
      end

      def create_scheme_seventeen_fee_types
        puts "Scheme 17 fee type count before: #{scheme_17_fee_type_count}".yellow
        require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: pretending?, stdout: false).call
        puts "Scheme 17 fee type count after: #{scheme_17_fee_type_count}".yellow
      end

      def remove_scheme_seventeen_fee_type_roles
        fee_types_with_scheme_17_role = Fee::BaseFeeType.agfs_scheme_17s

        if pretending?
          puts "Would remove agfs_scheme_17 role from #{fee_types_with_scheme_17_role.count} fee_types".yellow
        else
          ActiveRecord::Base.transaction do
            fee_types_with_scheme_17_role.each do |ft|
              if ft.roles == ['agfs_scheme_17']
                puts "Deleting fee type #{ft.description}".red
                ft.delete
              else
                puts "Removing agfs_scheme_17 role from #{ft.description}".green
                ft.roles.delete('agfs_scheme_17')
                ft.save!
              end
            end
          end
          puts "Fee types with scheme 17 role after: #{fee_types_with_scheme_17_role.count}".green
        end
      end
    end
  end
end
