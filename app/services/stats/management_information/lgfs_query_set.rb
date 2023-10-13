module Stats
  module ManagementInformation
    class LGFSQuerySet
      include Enumerable

      def each(&)
        set.each(&)
      end

      private

      def set
        { intake_fixed_fee: Stats::ManagementInformation::Queries::LGFS::IntakeFixedFeeQuery,
          intake_final_fee: Stats::ManagementInformation::Queries::LGFS::IntakeFinalFeeQuery,
          lf1_high_value: Stats::ManagementInformation::Queries::LGFS::LF1HighValueQuery,
          lf1_disk: Stats::ManagementInformation::Queries::LGFS::LF1DiskQuery,
          lf2_redetermination: Stats::ManagementInformation::Queries::LGFS::LF2RedeterminationQuery,
          lf2_high_value: Stats::ManagementInformation::Queries::LGFS::LF2HighValueQuery,
          lf2_disk: Stats::ManagementInformation::Queries::LGFS::LF2DiskQuery,
          written_reasons: Stats::ManagementInformation::Queries::LGFS::WrittenReasonsQuery,
          intake_interim_fee: Stats::ManagementInformation::Queries::LGFS::IntakeInterimFeeQuery }
      end
    end
  end
end
