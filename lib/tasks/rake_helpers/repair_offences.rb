require_relative 'rake_utils'
include Tasks::RakeHelpers::RakeUtils

module Tasks
  module RakeHelpers
    class RepairOffences
      def initialize(**kwargs)
        @data = CSV.read(kwargs[:file], headers: true)
        @output = File.open(kwargs[:output], 'a')
        @interactive = kwargs[:interactive]
        @dry_run = kwargs[:dry_run]
      end

      # Generate a repair file based on an input file with data from CCF
      #
      # Input file format;
      #
      #   CASE_NO,REP_ORD_NO,UNIQUE_CODE
      #   A12345678,9876543,UNIQUE_17.1
      def generate
        @output.puts 'cccd_id,case_no,maat_reference,cccd_offence_id'

        @data.each do |row|
          rep_orders = RepresentationOrder.includes(defendant: :claim).where(maat_reference: row['REP_ORD_NO'])
          claims = rep_orders.map(&:claim)

          offence = Offence.find_by(unique_code: row['UNIQUE_CODE'])

          if @interactive
            puts "Representation order: #{row['REP_ORD_NO']}"
            puts "Expected case number: #{row['CASE_NO']}"
            puts 'Found claims:'
            claims.each do |claim|
              puts "  Claim id: #{claim.id}"
              puts "  Case number: #{claim.case_number}"
              if claim.offence_id
                puts "  Existing offence: #{claim.offence_id} [#{claim.offence.unique_code}]"
              else
                puts '  No existing offence'
              end
            end
            puts "Intended offence: #{offence.id} [#{offence.unique_code}]"

            continue?
          end

          claims.each do |claim|
            next unless claim.case_number == row['CASE_NO']
            @output.puts("#{claim&.id},#{row['CASE_NO']},#{row['REP_ORD_NO']},#{offence&.id}")
          end
        end    
      end

      # Apply a repair file to add offences to claims
      #
      # Input file format;
      #
      #   cccd_id,case_no,maat_reference,cccd_offence_id
      #   1,A12345678,9876543,99
      def repair
        @data.each do |row|
          claim = Claim::BaseClaim.find_by(id: row['cccd_id'])
          next unless claim

          if @interactive
            puts "Claim id: #{claim.id}"
            puts "Case number: #{claim.case_number}"
            puts "Expected case number: #{row['case_no']}"
            puts "Offence to add: #{row['cccd_offence_id']}"
            if claim.offence_id
              puts "  Existing offence: #{claim.offence_id} [#{claim.offence.unique_code}]"
            else
              puts '  No existing offence'
            end

            continue?
            puts
          end

          @output.puts "Case number: #{claim.case_number}"
          @output.puts "Offence id: #{row['cccd_offence_id']}"
          if claim.offence.nil?
            offence = Offence.find(row['cccd_offence_id'])
            if @dry_run
              @output.puts '  Would update [dry run]'
            else
              @output.puts '  Updating'
              claim.offence = offence
              claim.save
            end
          else
            @output.puts '  Not updating'
            if claim.offence_id != row['cccd_offence_id'].to_i
              @output.puts 'Offence mismatch:'
              @output.puts "  Expected id: #{row['cccd_offence_id']}"
              @output.puts "  Actual id: #{claim.offence_id}"
            end
          end
          @output.puts '-------'
        end
      end
    end
  end
end

