module Stats
  module ManagementInformation
    class AGFSQuerySet
      include Enumerable

      def each(&)
        set.each(&)
      end

      private

      def set
        { intake_fixed_fee: AGFS::IntakeFixedFeeQuery,
          intake_final_fee: AGFS::IntakeFinalFeeQuery,
          af1_high_value: AGFS::Af1HighValueQuery,
          af1_disk: AGFS::Af1DiskQuery,
          af2_redetermination: AGFS::Af2RedeterminationQuery,
          af2_high_value: AGFS::Af2HighValueQuery,
          af2_disk: AGFS::Af2DiskQuery,
          written_reasons: AGFS::WrittenReasonsQuery }
      end
    end
  end
end
