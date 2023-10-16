module Stats
  module ManagementInformation
    class LGFSQuerySet
      include Enumerable

      def each(&)
        set.each(&)
      end

      private

      def set
        { intake_fixed_fee: LGFS::IntakeFixedFeeQuery,
          intake_final_fee: LGFS::IntakeFinalFeeQuery,
          lf1_high_value: LGFS::Lf1HighValueQuery,
          lf1_disk: LGFS::Lf1DiskQuery,
          lf2_redetermination: LGFS::Lf2RedeterminationQuery,
          lf2_high_value: LGFS::Lf2HighValueQuery,
          lf2_disk: LGFS::Lf2DiskQuery,
          written_reasons: LGFS::WrittenReasonsQuery,
          intake_interim_fee: LGFS::IntakeInterimFeeQuery }
      end
    end
  end
end
