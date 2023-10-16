module Seeds
  module Schemas
    class CleanLGFSFeeScheme10
      attr_reader :pretend
      alias_method :pretending?, :pretend

      class MissingSchemeNineOffence < StandardError; end
      class SchemeTenOffenceExists < StandardError; end

      def initialize(pretend: false, quiet: false)
        @pretend = pretend
        @quiet = quiet
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
          puts "Offence: #{offence.unique_code}" unless @quiet
          puts "  #{offence.description[0, 60]}" unless @quiet
          puts "  #{offence.offence_class.description[0, 60]}" unless @quiet
          Offence.transaction do
            new_offence = scheme_nine_offence_for(offence)
            update_claims(offence.claims, new_offence)
            add_scheme_ten_to(new_offence)
            remove_redundant(offence)
          end
          puts "-----" unless @quiet
        end
      end

      def down
        all_lgfs_offences.each do |offence|
          puts "Offence: #{offence.unique_code}" unless @quiet
          puts "  #{offence.description[0, 60]}" unless @quiet
          puts "  #{offence.offence_class.description[0, 60]}" unless @quiet
          Offence.transaction do
            create_scheme_ten_offence_for(offence)
          end
          puts "-----" unless @quiet
        end
      end

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

      def create_scheme_ten_offence_for(offence)
        if offence.unique_code.match(/~10/)
          puts "    [NOT-DUPLICATING] Offence #{offence.unique_code}".yellow
          return
        end
        begin
          new_offence = offence.dup
          new_offence.id = 7999 + offence.id # lib/tasks/lgfs_scheme_ten.rake starts adding ids at 8000
          new_offence.unique_code = new_offence.unique_code + '~10'
          new_offence.fee_schemes = [fee_scheme_ten]
          # claims = offence.claims.select { |claim| claim.fee_scheme == fee_scheme_ten }
          raise SchemeTenOffenceExists unless new_offence.valid?
          if pretending?
            puts "    [WOULD-CREATE] Offence #{new_offence.id}/#{new_offence.unique_code}".yellow unless @quiet
            puts "    [WOULD-REMOVE] Fee scheme 10 from offence #{offence.unique_code}".yellow unless @quiet
            # puts "    [WOULD-UPDATE] Move #{claims.count} fee scheme 10 claims (out of #{offence.claims.count}) to new offence".yellow unless @quiet
          else
            puts "    [CREATE] Offence #{new_offence.id}/#{new_offence.unique_code}".green unless @quiet
            new_offence.save!
            puts "      [SUCCESS]".green unless @quiet
            puts "    [REMOVE] Fee scheme 10 from offence #{offence.unique_code}".green unless @quiet
            offence.fee_schemes.delete(fee_scheme_ten)
            # puts "    [UPDATE] Move #{claims.count} fee scheme 10 claims (out of #{offence.claims.count}) to new offence".green unless @quiet
            # # It should be possible to do update_claims(claims, new_offence) but claims is an array instead of an ActiveRecord collection
            # offence.claims.each do |claim|
            #   if claim.offence == offence
            #     claim.offence = new_offence
            #     claim.save
            #   else
            #     puts "    [ERROR] Claim #{claim.id} does not have offence #{offence.unique_code}".red unless @quiet
            #   end
            # end
          end
        rescue SchemeTenOffenceExists, ActiveRecord::RecordNotUnique
          puts "      [FAILED]".red unless @quiet
        end
      end

      def offences_match?(first, second)
        return false if first.nil? || second.nil?

        (first.description == second.description) && (first.offence_class_id == second.offence_class_id)
      end

      def update_claims(claims, new_offence)
        if pretending?
          puts "    [WOULD-UPDATE] #{claims.count} claims".yellow unless @quiet
        else
          puts "    [UPDATE] #{claims.count} claims".green unless @quiet
          claims.update_all(offence_id: new_offence.id)
        end
      end

      def add_scheme_ten_to(offence)
        if pretending?
          puts "    [WOULD-UPDATE] Add fee scheme '#{display_fee_schemes(fee_scheme_ten)}' to offence #{offence.unique_code}".yellow unless @quiet
        else
          puts "    [UPDATE] Add fee scheme '#{display_fee_schemes(fee_scheme_ten)}' to offence #{offence.unique_code}".green unless @quiet
          puts "      [UPDATE] Before: #{display_fee_schemes(*offence.fee_schemes)}".green unless @quiet
          offence.fee_schemes << fee_scheme_ten
          offence.reload
          puts "      [UPDATE] After: #{display_fee_schemes(*offence.fee_schemes)}".green unless @quiet
        end
      end

      def display_fee_schemes(*fee_schemes)
        fee_schemes.map { |fs| "#{fs.name} #{fs.version}" }.join(', ')
      end

      def remove_redundant(offence)
        if pretending?
          puts "    [WOULD-REMOVE] Offence #{offence.unique_code}".yellow unless @quiet
        else
          puts "    [REMOVE] Offence #{offence.unique_code}".green unless @quiet
          offence.destroy
        end
      end
    end
  end
end
