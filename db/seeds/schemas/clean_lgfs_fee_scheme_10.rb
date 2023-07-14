module Seeds
  module Schemas
    class CleanLgfsFeeScheme10
      attr_reader :pretend
      alias_method :pretending?, :pretend

      class MissingSchemeNineOffence < StandardError; end

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
        puts "Offences linked to any LGFS fee scheme:     #{all_lgfs_offences.count}"
        puts "Offences linked only to LGFS scheme 9:      #{lgfs_scheme_nine_only.count}"
        puts "Offences linked only to LGFS scheme 10:     #{lgfs_scheme_ten_only.count}"
        puts "Offences linked to LGFS scheme 9 and 10:    #{lgfs_scheme_nine_or_ten.count}"
        puts
        puts "LGFS scheme 10 offences attached to claims: #{lgfs_scheme_ten_only_with_claims.count}"
        lgfs_scheme_ten_only_with_claims.each do |offence|
          puts "  Offence: #{offence.description}"
          puts "    #{offence.offence_class.description}"
          puts "    Unique code:                  #{offence.unique_code}"
          begin
            scheme_nine_offence_for(offence)
            puts '    Scheme 9 offence exists:      Yes'
          rescue MissingSchemeNineOffence
            puts '    Scheme 9 offence exists:      No'
          end
          puts "    Claim ids:"
          offence.claims.each do |claim|
            puts "      #{claim.id}"
          end
        end
      end

      def up
        lgfs_scheme_ten_only.each do |offence|
          puts "Offence: #{offence.unique_code}"
          puts "  #{offence.description[0, 60]}"
          puts "  #{offence.offence_class.description[0, 60]}"
          Offence.transaction do
            new_offence = scheme_nine_offence_for(offence)
            update_claims_for(offence, new_offence)
            add_scheme_ten_to(new_offence)
            remove_redundant(offence)
          end
          puts "-----"
        end
      end

    #   def down
    #   end

      private

      def fee_scheme_nine = @fee_scheme_nine ||= FeeScheme.lgfs.nine.first
      def fee_scheme_ten = @fee_scheme_ten ||= FeeScheme.lgfs.ten.first

      def all_lgfs_offences = @all_lgfs_offences ||= Offence.joins(:fee_schemes).merge(FeeScheme.lgfs).distinct
      def lgfs_scheme_nine_only = all_lgfs_offences.select { |o| o.fee_schemes & [fee_scheme_nine, fee_scheme_ten] == [fee_scheme_nine] }
      def lgfs_scheme_ten_only = all_lgfs_offences.select { |o| o.fee_schemes & [fee_scheme_nine, fee_scheme_ten] == [fee_scheme_ten] }
      def lgfs_scheme_nine_or_ten = all_lgfs_offences.select { |o| (o.fee_schemes & [fee_scheme_nine, fee_scheme_ten]).sort == [fee_scheme_nine, fee_scheme_ten].sort }

      def lgfs_scheme_ten_only_with_claims = lgfs_scheme_ten_only.select { |o| o.claims.count.positive? }

      def scheme_nine_offence_for(offence)
        code = offence.unique_code.gsub(/~.*$/, '')
        Offence.find_by(unique_code: code).tap do |new_offence|
          raise MissingSchemeNineOffence unless offences_match?(offence, new_offence)
        end
      end

      def offences_match?(first, second)
        return false if first.nil? || second.nil?

        (first.description == second.description) && (first.offence_class_id == second.offence_class_id)
      end

      def update_claims_for(offence, new_offence)
        puts "  Claims to update: #{offence.claims.count}"
        offence.claims.each do |claim|
          if pretending?
            puts "    [WOULD-UPDATE] Claim id #{claim.id}".yellow
          else
            puts "    [UPDATE] Claim id #{claim.id}".green
            claim.offence = new_offence
            claim.save!
          end
        end
      end

      def add_scheme_ten_to(offence)
        if pretending?
          puts "    [WOULD-UPDATE] Add fee scheme '#{display_fee_schemes(fee_scheme_ten)}' to offence #{offence.unique_code}".yellow
        else
          puts "    [UPDATE] Add fee scheme '#{display_fee_schemes(fee_scheme_ten)}' to offence #{offence.unique_code}".green
          puts "      [UPDATE] Before: #{display_fee_schemes(*offence.fee_schemes)}".green
          offence.fee_schemes << fee_scheme_ten
          offence.reload
          puts "      [UPDATE] After: #{display_fee_schemes(*offence.fee_schemes)}".green
        end
      end

      def display_fee_schemes(*fee_schemes)
        fee_schemes.map { |fs| "#{fs.name} #{fs.version}" }.join(', ')
      end

      def remove_redundant(offence)
        if pretending?
          puts "    [WOULD-REMOVE] Offence #{offence.unique_code}".yellow
        else
          puts "    [REMOVE] Offence #{offence.unique_code}".green
          offence.destroy
        end
      end
    end
  end
end
