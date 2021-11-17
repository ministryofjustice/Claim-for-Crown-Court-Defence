module Stats
  module ManagementInformation
    class LgfsQuerySet
      include Enumerable

      def each(&block)
        set.each(&block)
      end

      private

      def set
        { intake_fixed_fee: Lgfs::IntakeFixedFeeQuery,
          intake_final_fee: Lgfs::IntakeFinalFeeQuery,
          lf1_high_value: Lgfs::Lf1HighValueQuery,
          lf1_disk: Lgfs::Lf1DiskQuery,
          lf2_redetermination: Lgfs::Lf2RedeterminationQuery,
          lf2_high_value: Lgfs::Lf2HighValueQuery,
          lf2_disk: Lgfs::Lf2DiskQuery,
          written_reasons: Lgfs::WrittenReasonsQuery,
          intake_interim_fee: Lgfs::IntakeInterimFeeQuery }
      end
    end
  end
end
