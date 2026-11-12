require Rails.root.join('db', 'seeds', 'fee_types', 'csv_seeder')

module Seeds
  module Schemas
    class AddAGFSFeeScheme18
      attr_reader :pretend
      alias pretending? pretend

      def initialize(pretend: false)
        @pretend = pretend
      end

      def status
        scheme = FeeScheme.agfs.version(18).first
        <<~STATUS
          AGFS scheme 17 end date: #{FeeScheme.agfs.version(17).first&.end_date || 'nil'}
          AGFS scheme 18 fee scheme: #{scheme&.attributes || 'nil'}
          AGFS scheme 18 offence count: #{offence_count}
          AGFS scheme 18 total fee_type count: #{fee_type_count}
          ------------------------------------------------------------
          Status: #{scheme.present? && offence_count.positive? ? 'up' : 'down'}
        STATUS
      end

      def up
        return preview('seed') if pretending?

        ActiveRecord::Base.transaction do
          create_agfs_scheme_eighteen
          set_agfs_scheme_eighteen_offences
          create_scheme_eighteen_fee_types
        end
        status
      end

      def down
        return preview('roll back') if pretending?

        ActiveRecord::Base.transaction do
          remove_scheme_eighteen_fee_type_roles
          unset_agfs_scheme_eighteen_offences
          destroy_agfs_scheme_eighteen
        end
        status
      end

      private

      def create_agfs_scheme_eighteen
        end_date = Settings.agfs_scheme_18_start_date.beginning_of_day - 1.second
        progress("Updating AGFS scheme 17 end date to #{end_date}")
        FeeScheme.agfs.version(17).first!.update!(end_date: end_date)
        progress("Finding or creating AGFS scheme 18 starting #{Settings.agfs_scheme_18_start_date}")
        FeeScheme.find_or_create_by!(name: 'AGFS', version: 18) do |record|
          record.start_date = Settings.agfs_scheme_18_start_date.beginning_of_day
        end
      end

      def set_agfs_scheme_eighteen_offences
        progress("Scheme 18 offence count before: #{offence_count}")
        scheme = FeeScheme.agfs.version(18).first!
        FeeScheme.agfs.version(17).first!.offences.each do |offence|
          offence.fee_schemes << scheme unless offence.fee_schemes.include?(scheme)
        end
        progress("Scheme 18 offence count after: #{offence_count}", :green)
      end

      def create_scheme_eighteen_fee_types
        progress("Scheme 18 fee type count before: #{fee_type_count}")
        Seeds::FeeTypes::CsvSeeder.new(dry_mode: false, stdout: true).call
        progress("Scheme 18 fee type count after: #{fee_type_count}", :green)
      end

      def unset_agfs_scheme_eighteen_offences
        scheme = FeeScheme.agfs.version(18).first
        progress("Scheme 18 offence count before: #{offence_count}")
        removed = scheme&.offence_fee_schemes&.delete_all || 0
        progress("Offence associations removed: #{removed}", :green)
        progress("Scheme 18 offence count after: #{offence_count}", :green)
      end

      def destroy_agfs_scheme_eighteen
        scheme = FeeScheme.agfs.version(18).first
        progress('Deleted AGFS scheme 18', :red) if scheme&.destroy!
        previous = FeeScheme.agfs.version(17).first
        progress('Updated AGFS scheme 17 end date to nil', :green) if previous&.update!(end_date: nil)
      end

      def remove_scheme_eighteen_fee_type_roles
        before_count = fee_type_count
        progress("Scheme 18 fee type count before: #{before_count}")
        Fee::BaseFeeType.agfs_scheme_18s.each { |fee_type| remove_role(fee_type) }
        progress("Fee types updated or removed: #{before_count - fee_type_count}", :green)
        progress("Scheme 18 fee type count after: #{fee_type_count}", :green)
      end

      def remove_role(fee_type)
        if fee_type.roles == ['agfs_scheme_18']
          progress("Deleting fee type #{fee_type.description}", :red)
          fee_type.delete
        else
          progress("Removing agfs_scheme_18 role from #{fee_type.description}")
          fee_type.roles.delete('agfs_scheme_18')
          fee_type.save!
        end
      end

      def offence_count
        Offence.joins(:fee_schemes).merge(FeeScheme.agfs.version(18)).distinct.count
      end

      def fee_type_count
        Fee::BaseFeeType.agfs_scheme_18s.count
      end

      def preview(action)
        progress("Would #{action} AGFS scheme 18 (start date: #{Settings.agfs_scheme_18_start_date}); no records updated")
        status
      end

      def progress(message, color = :yellow)
        $stdout.puts Rainbow(message).public_send(color)
      end
    end
  end
end
