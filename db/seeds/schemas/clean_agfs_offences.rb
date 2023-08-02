module Seeds
  module Schemas
    class CleanAgfsOffences
      attr_reader :pretend
      alias_method :pretending?, :pretend

      class MissingOffence < StandardError; end
      class SchemeElevenOffenceExists < StandardError; end
      class SchemeTwelveOffenceExists < StandardError; end
      class SchemeThirteenOffenceExists < StandardError; end

      def initialize(pretend: false, quiet: false)
        @pretend = pretend
        @quiet = quiet
        @output_file_dir = File.expand_path("tmp/#{Time.now.strftime('%H-%M-%S')}", Rails.root)
      end

      def status
        Dir.mkdir(@output_file_dir)
        puts "Offences linked to any AGFS fee scheme:                   #{all_agfs_offences.count}"
        status_summary('Offences linked only to AGFS scheme 9', agfs_scheme_nine_only)
        status_summary('Offences linked only to AGFS scheme 10', agfs_scheme_ten_only)
        status_summary('Offences linked only to AGFS scheme 11', agfs_scheme_eleven_only)
        status_summary('Offences linked only to AGFS scheme 12', agfs_scheme_twelve_only)
        status_summary('Offences linked only to AGFS scheme 13', agfs_scheme_thirteen_only)
        status_summary('Offences linked only to AGFS scheme 14', agfs_scheme_fourteen_only)
        status_summary('Offences linked only to AGFS scheme 15', agfs_scheme_fifteen_only)
        status_summary('Offences linked only to AGFS scheme 11, 14 or 15', agfs_scheme_11_14_15_only)
        status_summary('Offences linked only to AGFS scheme 10, 11, 14 or 15', agfs_scheme_10_11_14_15_only)
        status_summary('Offences linked only to AGFS scheme 11, 12, 13, 14 or 15', agfs_scheme_11_12_13_14_15_only)
        status_summary('Offences linked only to any AGFS scheme', all_agfs_offences)
        puts
        puts "Scheme 11, 14 and 15 offences - compared with scheme 10 offences"
        fee_scheme_compare(agfs_scheme_11_14_15_only, '~11', '')
        puts
        puts "Scheme 11, 12, 13, 14 and 15 offences - compared with scheme 10 offences"
        fee_scheme_compare(agfs_scheme_11_12_13_14_15_only, '~11', '')
        puts
        puts "Scheme 12 offences - compared with scheme 11 offences"
        fee_scheme_compare(agfs_scheme_twelve_only, '~12', '~11')
        puts
        puts "Scheme 13 offences - compared with scheme 11 offences"
        fee_scheme_compare(agfs_scheme_thirteen_only, '~13', '~11')
      end

      def merge_11
        fee_scheme_eleven.offences.each do |offence|
          puts "Offence: #{offence.unique_code}" unless @quiet
          puts "  #{offence.description[0, 60]}" unless @quiet
          puts "  #{offence.offence_band.description} " unless @quiet
          puts "  #{offence.offence_band.offence_category.description[0, 60]}" unless @quiet

          Offence.transaction do
            new_offence = scheme_ten_offence_for(offence)
            if new_offence
              update_claims(offence.claims, new_offence)
              copy_schemes(from: offence, to: new_offence)
              remove_redundant(offence)
            else
              if pretending?
                puts "    [WOULD-UPDATE] Unique code of #{offence.unique_code}".yellow unless @quiet
              else
                puts "    [UPDATE] Unique code of #{offence.unique_code}".green unless @quiet
                puts "      [BEFORE] #{offence.unique_code}".green unless @quiet
                offence.unique_code.gsub!('~11', '')
                offence.save!
                puts "      [AFTER] #{offence.unique_code}".green unless @quiet
              end
            end
          end
          puts "-----" unless @quiet
        end
      end

      def merge_12
        agfs_scheme_twelve_only.each do |offence|
          puts "Offence: #{offence.unique_code}" unless @quiet
          puts "  #{offence.description[0, 60]}" unless @quiet
          puts "  #{offence.offence_band.description} " unless @quiet
          puts "  #{offence.offence_band.offence_category.description[0, 60]}" unless @quiet

          Offence.transaction do
            new_offence = scheme_eleven_offence_for(offence)
            update_claims(offence.claims, new_offence)
            add_scheme_twelve_to(new_offence)
            remove_redundant(offence)
          end
          puts "-----" unless @quiet
        end
      end

      def merge_13
        agfs_scheme_thirteen_only.each do |offence|
          puts "Offence: #{offence.unique_code}" unless @quiet
          puts "  #{offence.description[0, 60]}" unless @quiet
          puts "  #{offence.offence_band.description} " unless @quiet
          puts "  #{offence.offence_band.offence_category.description[0, 60]}" unless @quiet

          Offence.transaction do
            new_offence = scheme_eleven_offence_for(offence)
            update_claims(offence.claims, new_offence)
            add_scheme_thirteen_to(new_offence)
            remove_redundant(offence)
          end
          puts "-----" unless @quiet
        end
      end

      def rollback
        fee_scheme_eleven.offences.each do |offence|
          puts "Offence: #{offence.unique_code}" unless @quiet
          puts "  #{offence.description[0, 60]}" unless @quiet
          puts "  #{offence.offence_band.description[0, 60]}" unless @quiet
          puts "  #{offence.offence_band.offence_category.description[0, 60]}" unless @quiet

          # Filter list of claims outside of the transaction to avoid locking the database
          scheme_eleven_claims = offence.claims.select { |claim| claim.fee_scheme == fee_scheme_eleven }
          scheme_twelve_claims = offence.claims.select { |claim| claim.fee_scheme == fee_scheme_twelve }
          scheme_thirteen_claims = offence.claims.select { |claim| claim.fee_scheme == fee_scheme_thirteen }

          Offence.transaction do
            create_scheme_eleven_offence_for(offence, scheme_eleven_claims)
            create_scheme_twelve_offence_for(offence, scheme_twelve_claims)
            create_scheme_thirteen_offence_for(offence, scheme_thirteen_claims)
          end
          puts "-----" unless @quiet
        end
      end

      private

      def status_summary(title, offences)
        puts "%-57s %i" % ["#{title}:", offences.count]
        puts "  First id: #{offences.pluck(:id).min}; Last id: #{offences.pluck(:id).max}" if offences.count.positive?
        filename = "#{@output_file_dir}/#{title.gsub(' ', '-')}.txt"
        File.open(filename, 'w') do |file|
          claim_count = offences.sort_by(&:id).sum do |offence|
            file.puts "#{offence.id}: #{offence.description}"
            file.puts "  web: #{offence.claims.where(source: 'web').order(:id).pluck(:id).join(', ')}"
            file.puts "  api: #{offence.claims.where(source: 'api').order(:id).pluck(:id).join(', ')}"
            file.puts "  awe: #{offence.claims.where(source: 'api_web_edited').order(:id).pluck(:id).join(', ')}"
            offence.claims.count
          end
          puts "  Claims: #{claim_count}"
          puts "  Ids written to: #{filename}"
        end
      end

      def scheme_ten_offence_for(offence)
        code = offence.unique_code.gsub(/~.*$/, '')
        Offence.find_by(unique_code: code)
      end

      def scheme_eleven_offence_for(offence)
        code = offence.unique_code.gsub(/~.*$/, '~11')
        Offence.find_by(unique_code: code).tap do |new_offence|
          raise MissingOffence unless offences_match?(offence, new_offence)
        end
      end

      def update_claims(claims, new_offence)
        if pretending?
          puts "    [WOULD-UPDATE] #{claims.count} claims".yellow unless @quiet
        else
          puts "    [UPDATE] #{claims.count} claims".green unless @quiet
          claims.update_all(offence_id: new_offence.id)
        end
      end

      def update_claims_with_ids(claims, new_offence)
        if pretending?
          puts "    [WOULD-UPDATE] #{claims.count} claims".yellow unless @quiet
        else
          puts "    [UPDATE] #{claims.count} claims".green unless @quiet
          Claim::BaseClaim.where(id: claims.map(&:id)).update_all(offence_id: new_offence.id)
        end
      end

      def copy_schemes(from:, to:)
        if pretending?
          puts "    [WOULD-COPY] Fee schemes #{display_fee_schemes(*from.fee_schemes)} from offence #{from.unique_code} to offence #{to.unique_code}".yellow unless @quiet
        else
          puts "    [COPY] Fee schemes #{display_fee_schemes(*from.fee_schemes)} from offence #{from.unique_code} to offence #{to.unique_code}".green unless @quiet
          puts "      [UPDATE] Before: #{display_fee_schemes(*to.fee_schemes)}".green unless @quiet
          to.fee_schemes.append(*from.fee_schemes)
          to.reload
          puts "      [UPDATE] After: #{display_fee_schemes(*to.fee_schemes)}".green unless @quiet
        end
      end

      def add_scheme_twelve_to(offence)
        if pretending?
          puts "    [WOULD-UPDATE] Add fee scheme '#{display_fee_schemes(fee_scheme_twelve)}' to offence #{offence.unique_code}".yellow unless @quiet
        else
          puts "    [UPDATE] Add fee scheme '#{display_fee_schemes(fee_scheme_twelve)}' to offence #{offence.unique_code}".green unless @quiet
          puts "      [UPDATE] Before: #{display_fee_schemes(*offence.fee_schemes)}".green unless @quiet
          offence.fee_schemes << fee_scheme_twelve
          offence.reload
          puts "      [UPDATE] After: #{display_fee_schemes(*offence.fee_schemes)}".green unless @quiet
        end
      end

      def add_scheme_thirteen_to(offence)
        if pretending?
          puts "    [WOULD-UPDATE] Add fee scheme '#{display_fee_schemes(fee_scheme_thirteen)}' to offence #{offence.unique_code}".yellow unless @quiet
        else
          puts "    [UPDATE] Add fee scheme '#{display_fee_schemes(fee_scheme_thirteen)}' to offence #{offence.unique_code}".green unless @quiet
          puts "      [UPDATE] Before: #{display_fee_schemes(*offence.fee_schemes)}".green unless @quiet
          offence.fee_schemes << fee_scheme_thirteen
          offence.reload
          puts "      [UPDATE] After: #{display_fee_schemes(*offence.fee_schemes)}".green unless @quiet
        end
      end

      def create_scheme_eleven_offence_for(offence, claims)
        if offence.unique_code.match(/~/)
          puts "    [NOT-DUPLICATING] Offence #{offence.unique_code}".yellow
          return
        end
        begin
          if offence.fee_schemes.include?(fee_scheme_ten)
            # New offence needs to be created to distinguish from the fee scheme 10 version
            new_offence = offence.dup
            new_offence.unique_code = "#{new_offence.unique_code}~11"
            new_offence.fee_schemes = [fee_scheme_eleven, fee_scheme_fourteen, fee_scheme_fifteen]
            raise SchemeElevenOffenceExists unless new_offence.valid?
            if pretending?
              puts "    [WOULD-CREATE] Offence #{new_offence.id}/#{new_offence.unique_code}".yellow unless @quiet
              puts "    [WOULD-REMOVE] Fee schemes 11, 14 and 15 from offence #{offence.unique_code}".yellow unless @quiet
              puts "    [WOULD-UPDATE] Move #{claims.count} fee scheme 12 claims (out of #{offence.claims.count}) to new offence".yellow unless @quiet
            else
              puts "    [CREATE] Offence #{new_offence.id}/#{new_offence.unique_code}".green unless @quiet
              new_offence.save!
              puts "      [SUCCESS]".green unless @quiet
              puts "    [REMOVE] Fee scheme 11, 14, 15 from offence #{offence.unique_code}".green unless @quiet
              offence.fee_schemes.delete(fee_scheme_eleven)
              offence.fee_schemes.delete(fee_scheme_fourteen)
              offence.fee_schemes.delete(fee_scheme_fifteen)
              puts "    [UPDATE] Move #{claims.count} fee scheme 12 claims (out of #{offence.claims.count}) to new offence".green unless @quiet
              update_claims_with_ids(claims, new_offence)
            end
          else
            # Offence is updated as it does not apply to fee scheme 10
            if pretending?
              puts "    [WOULD-UPDATE] Offence unique code from #{offence.unique_code} to #{offence.unique_code}~11".yellow unless @quiet
            else
              puts "    [UPDATE] Offence unique code from #{offence.unique_code} to #{offence.unique_code}~11".green unless @quiet
              offence.unique_code = "#{offence.unique_code}~11"
              offence.save!
              puts "      [SUCCESS]".green unless @quiet
            end
          end
        rescue SchemeTwelveOffenceExists, ActiveRecord::RecordNotUnique
          puts "      [FAILED]".red unless @quiet
        end
      end

      def create_scheme_twelve_offence_for(offence, claims)
        if offence.unique_code.match(/~/) && !offence.unique_code.match(/~11/)
          puts "    [NOT-DUPLICATING] Offence #{offence.unique_code}".yellow
          return
        end
        begin
          new_offence = offence.dup
          # # AGFS scheme 11 offences start at 3001
          # # lib/tasks/agfs_scheme_thirteen.rake starts adding ids at 5000
          # new_offence.id = 5000 + offence.id - 3000
          new_offence.unique_code = "#{new_offence.unique_code.gsub('~11', '')}~12"
          new_offence.fee_schemes = [fee_scheme_twelve]
          raise SchemeTwelveOffenceExists unless new_offence.valid?
          if pretending?
            puts "    [WOULD-CREATE] Offence #{new_offence.id}/#{new_offence.unique_code}".yellow unless @quiet
            puts "    [WOULD-REMOVE] Fee scheme 12 from offence #{offence.unique_code}".yellow unless @quiet
            puts "    [WOULD-UPDATE] Move #{claims.count} fee scheme 12 claims (out of #{offence.claims.count}) to new offence".yellow unless @quiet
          else
            puts "    [CREATE] Offence #{new_offence.id}/#{new_offence.unique_code}".green unless @quiet
            new_offence.save!
            puts "      [SUCCESS]".green unless @quiet
            puts "    [REMOVE] Fee scheme 12 from offence #{offence.unique_code}".green unless @quiet
            offence.fee_schemes.delete(fee_scheme_twelve)
            puts "    [UPDATE] Move #{claims.count} fee scheme 12 claims (out of #{offence.claims.count}) to new offence".green unless @quiet
            update_claims_with_ids(claims, new_offence)
          end
        rescue SchemeTwelveOffenceExists, ActiveRecord::RecordNotUnique
          puts "      [FAILED]".red unless @quiet
        end
      end

      def create_scheme_thirteen_offence_for(offence, claims)
        if offence.unique_code.match(/~/) && !offence.unique_code.match(/~11/)
          puts "    [NOT-DUPLICATING] Offence #{offence.unique_code}".yellow
          return
        end
        begin
          new_offence = offence.dup
          # # AGFS scheme 11 offences start at 3001
          # # lib/tasks/agfs_scheme_thirteen.rake starts adding ids at 10000
          # new_offence.id = 10000 + offence.id - 3000
          new_offence.unique_code = "#{new_offence.unique_code.gsub('~11', '')}~13"
          new_offence.fee_schemes = [fee_scheme_thirteen]
          raise SchemeThirteenOffenceExists unless new_offence.valid?
          if pretending?
            puts "    [WOULD-CREATE] Offence #{new_offence.id}/#{new_offence.unique_code}".yellow unless @quiet
            puts "    [WOULD-REMOVE] Fee scheme 13 from offence #{offence.unique_code}".yellow unless @quiet
            puts "    [WOULD-UPDATE] Move #{claims.count} fee scheme 13 claims (out of #{offence.claims.count}) to new offence".yellow unless @quiet
          else
            puts "    [CREATE] Offence #{new_offence.id}/#{new_offence.unique_code}".green unless @quiet
            new_offence.save!
            puts "      [SUCCESS]".green unless @quiet
            puts "    [REMOVE] Fee scheme 13 from offence #{offence.unique_code}".green unless @quiet
            offence.fee_schemes.delete(fee_scheme_thirteen)
            puts "    [UPDATE] Move #{claims.count} fee scheme 13 claims (out of #{offence.claims.count}) to new offence".green unless @quiet
            update_claims_with_ids(claims, new_offence)
          end
        rescue SchemeThirteenOffenceExists, ActiveRecord::RecordNotUnique
          puts "      [FAILED]".red unless @quiet
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

      def fee_scheme_compare(offences, fee_scheme_marker, other_fee_scheme_marker)
        claim_count = 0
        offences.each do |offence|
          unique_code = offence.unique_code
          other_unique_code = unique_code.gsub(fee_scheme_marker, other_fee_scheme_marker)
          other_offence = Offence.find_by(unique_code: other_unique_code)
          if !other_offence
            puts "    #{unique_code}: No equivalent offence".red
            generic_unique_code = unique_code.gsub(/_.*/, '')
            generic_offences = Offence.where('unique_code LIKE ?', "#{generic_unique_code}%")
            puts "      #{offence.description}"
            generic_offences.each do |o|
              next if o.unique_code.match(/~/)
              puts "      #{o.unique_code}: #{offence.description == o.description ? 'Description matches'.green : 'Description does not match'.red }"
            end
          elsif !offences_match?(offence, other_offence)
            puts "    #{unique_code}: Equivalent offence does not match".red
          end
          claim_count += offence.claims.count
        end
        puts "    Total number of claims: #{claim_count}"
      end

      def fee_scheme_nine = @fee_scheme_nine ||= FeeScheme.agfs.nine.first
      def fee_scheme_ten = @fee_scheme_ten ||= FeeScheme.agfs.ten.first
      def fee_scheme_eleven = @fee_scheme_eleven ||= FeeScheme.agfs.eleven.first
      def fee_scheme_twelve = @fee_scheme_twelve ||= FeeScheme.agfs.twelve.first
      def fee_scheme_thirteen = @fee_scheme_thirteen ||= FeeScheme.agfs.thirteen.first
      def fee_scheme_fourteen = @fee_scheme_fourteen ||= FeeScheme.agfs.version(14).first
      def fee_scheme_fifteen = @fee_scheme_fifteen ||= FeeScheme.agfs.version(15).first
      def all_fee_schemes
        [
          fee_scheme_nine,
          fee_scheme_ten,
          fee_scheme_eleven,
          fee_scheme_twelve,
          fee_scheme_thirteen,
          fee_scheme_fourteen,
          fee_scheme_fifteen
        ]
      end

      def all_agfs_offences = @all_agfs_offences ||= Offence.joins(:fee_schemes).merge(FeeScheme.agfs).distinct
      def agfs_scheme_nine_only = all_agfs_offences.select { |o| o.fee_schemes & all_fee_schemes == [fee_scheme_nine] }
      def agfs_scheme_ten_only = all_agfs_offences.select { |o| o.fee_schemes & all_fee_schemes == [fee_scheme_ten] }
      def agfs_scheme_eleven_only = all_agfs_offences.select { |o| o.fee_schemes & all_fee_schemes == [fee_scheme_eleven] }
      def agfs_scheme_twelve_only = all_agfs_offences.select { |o| o.fee_schemes & all_fee_schemes == [fee_scheme_twelve] }
      def agfs_scheme_thirteen_only = all_agfs_offences.select { |o| o.fee_schemes & all_fee_schemes == [fee_scheme_thirteen] }
      def agfs_scheme_fourteen_only = all_agfs_offences.select { |o| o.fee_schemes & all_fee_schemes == [fee_scheme_fourteen] }
      def agfs_scheme_fifteen_only = all_agfs_offences.select { |o| o.fee_schemes & all_fee_schemes == [fee_scheme_fifteen] }
      def agfs_scheme_11_14_15_only = all_agfs_offences.select { |o| (o.fee_schemes & all_fee_schemes).sort == [fee_scheme_eleven, fee_scheme_fourteen, fee_scheme_fifteen].sort }
      def agfs_scheme_10_11_14_15_only = all_agfs_offences.select { |o| (o.fee_schemes & all_fee_schemes).sort == [fee_scheme_ten, fee_scheme_eleven, fee_scheme_fourteen, fee_scheme_fifteen].sort }
      def agfs_scheme_11_12_13_14_15_only = all_agfs_offences.select { |o| (o.fee_schemes & all_fee_schemes).sort == [fee_scheme_eleven, fee_scheme_twelve, fee_scheme_thirteen, fee_scheme_fourteen, fee_scheme_fifteen].sort }

      def offences_match?(first, second)
        return false if first.nil? || second.nil?

        (first.description == second.description) && (first.offence_band_id == second.offence_band_id)
      end
    end
  end
end
