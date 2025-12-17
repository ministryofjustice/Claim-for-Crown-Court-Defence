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
    end
  end
end
