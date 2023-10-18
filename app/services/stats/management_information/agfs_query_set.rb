module Stats
  module ManagementInformation
    class AGFSQuerySet
      include Enumerable

      def each(&)
        set.each(&)
      end

      private

      def set
        { intake_fixed_fee: Stats::ManagementInformation::Queries::AGFS::IntakeFixedFeeQuery,
          intake_final_fee: Stats::ManagementInformation::Queries::AGFS::IntakeFinalFeeQuery,
          af1_high_value: Stats::ManagementInformation::Queries::AGFS::Af1HighValueQuery,
          af1_disk: Stats::ManagementInformation::Queries::AGFS::Af1DiskQuery,
          af2_redetermination: Stats::ManagementInformation::Queries::AGFS::Af2RedeterminationQuery,
          af2_high_value: Stats::ManagementInformation::Queries::AGFS::Af2HighValueQuery,
          af2_disk: Stats::ManagementInformation::Queries::AGFS::Af2DiskQuery,
          written_reasons: Stats::ManagementInformation::Queries::AGFS::WrittenReasonsQuery }
      end
    end
  end
end
