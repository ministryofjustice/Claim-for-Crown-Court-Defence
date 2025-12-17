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
          \sLGFS scheme 11 offence count: #{scheme_11_offence_count}
          \sLGFS scheme 11 total fee_type count: #{scheme_11_fee_type_count}
          \s------------------------------------------------------------
          Status: #{lgfs_fee_scheme_11.present? && scheme_11_offence_count > 0 ? 'up' : 'down'}
        STATUS
      end

      def up
        create_lgfs_scheme_eleven
        set_lgfs_scheme_eleven_offences
        # create_lgfs_scheme_eleven_fee_types
      end 

      def down
        unset_lgfs_scheme_eleven_offences
        # remove_lgfs_scheme_eleven_fee_type_roles
        destroy_lgfs_scheme_eleven
      end

      private

      def lgfs_fee_scheme_11
        @lgfs_fee_scheme_11 ||= FeeScheme.lgfs.eleven.first
      end

      def lgfs_fee_scheme_10
        @lgfs_fee_scheme_10 ||= FeeScheme.lgfs.ten.first
      end

      def scheme_11_offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.version(11)).merge(FeeScheme.lgfs).distinct.count
      end

      def scheme_11_fee_type_count
        Fee::BaseFeeType.lgfs_scheme_11s.count
      end

      def create_lgfs_scheme_eleven
        print "Finding LGFS scheme 10".yellow
        lgfs_fee_scheme_ten = FeeScheme.find_by(name: 'LGFS', version: 10, start_date: Settings.lgfs_scheme_10_clair_release_date.beginning_of_day)
        lgfs_fee_scheme_ten ? print("...found\n".green) : print("...not found\n".red)

        print "Updating LGFS scheme 10 end date to #{Settings.lgfs_scheme_11_csfr.end_of_day-1.day}".yellow
        if pretending?
          print "...not updated\n".green if pretending?
        else
          if lgfs_fee_scheme_ten.update(end_date: Settings.lgfs_scheme_11_csfr.end_of_day - 1.day)
            print "...updated\n".green
          else
            print "...failed to update: #{lgfs_fee_scheme_ten.errors.full_messages.join(', ')}\n".red
          end
        end

        print "Finding or creating LGFS fee scheme 11 with start date #{Settings.lgfs_scheme_11_csfr.beginning_of_day}...".yellow
        if pretending?
          print "...not created\n".green if pretending?
        else
          FeeScheme.find_or_create_by(name: 'LGFS', version: 11, start_date: Settings.lgfs_scheme_11_csfr.beginning_of_day)
          print "...created\n".green
        end
      end

      def destroy_lgfs_scheme_eleven
        if pretending?
          puts "Would delete fee scheme 11: #{lgfs_fee_scheme_11&.attributes || 'does not exist'}".yellow
          puts "Would update #{lgfs_fee_scheme_10.attributes} end date to nil".yellow
        else
          puts 'Deleted LGFS fee scheme 11'.green if lgfs_fee_scheme_11&.destroy
          print "Updating LGFS scheme 10 end date to nil".yellow
          lgfs_fee_scheme_10.update(end_date: nil)
          print "...updated\n".green
        end
      end

      def set_lgfs_scheme_eleven_offences
        puts "Setting LGFS scheme 10 offences to include scheme 11".yellow
        puts "Scheme LGFS 11 offence count before: #{scheme_11_offence_count}".yellow
        Offence.transaction do
          lgfs_scheme_ten_offences.each do |offence|
            if pretending?
              puts "Would add LGFS scheme 11 to offence #{offence.unique_code}".yellow
            else
              next if offence.fee_schemes.include? lgfs_fee_scheme_11

              offence.fee_schemes << lgfs_fee_scheme_11
              puts "Added LGFS scheme 11 to offence #{offence.unique_code}".green
            end
          end
        end
        puts
        puts "Scheme LGFS 11 offence count after: #{scheme_11_offence_count}".yellow
      end

      def unset_lgfs_scheme_eleven_offences
        Offence.transaction do
          Offence.joins(:fee_schemes).merge(FeeScheme.version(11)).merge(FeeScheme.lgfs).distinct.each do |offence|
            if pretending?
              puts "Would remove LGFS scheme 11 from offence #{offence.unique_code}".yellow
            else
              offence.fee_schemes.delete(lgfs_fee_scheme_11)
              puts "Removed LGFS scheme 11 from offence #{offence.unique_code}".green
            end
          end
        end
        puts
        puts "Scheme LGFS 11 offence count after unset: #{scheme_11_offence_count}".yellow
      end

      def lgfs_scheme_ten_offences
        Offence.joins(:fee_schemes).merge(FeeScheme.version(10)).merge(FeeScheme.lgfs).distinct
      end
    end
  end
end
