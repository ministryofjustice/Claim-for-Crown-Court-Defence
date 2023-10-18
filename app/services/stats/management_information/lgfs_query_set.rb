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
          lf1_high_value: Stats::ManagementInformation::Queries::LGFS::Lf1HighValueQuery,
          lf1_disk: Stats::ManagementInformation::Queries::LGFS::Lf1DiskQuery,
          lf2_redetermination: Stats::ManagementInformation::Queries::LGFS::Lf2RedeterminationQuery,
          lf2_high_value: Stats::ManagementInformation::Queries::LGFS::Lf2HighValueQuery,
          lf2_disk: Stats::ManagementInformation::Queries::LGFS::Lf2DiskQuery,
          written_reasons: Stats::ManagementInformation::Queries::LGFS::WrittenReasonsQuery,
          intake_interim_fee: Stats::ManagementInformation::Queries::LGFS::IntakeInterimFeeQuery }
      end
    end
  end
end
