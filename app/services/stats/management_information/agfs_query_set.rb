module Stats
  module ManagementInformation
    class AgfsQuerySet
      include Enumerable

      def each(&)
        set.each(&)
      end

      private

      def set
        { intake_fixed_fee: Agfs::IntakeFixedFeeQuery,
          intake_final_fee: Agfs::IntakeFinalFeeQuery,
          af1_high_value: Agfs::Af1HighValueQuery,
          af1_disk: Agfs::Af1DiskQuery,
          af2_redetermination: Agfs::Af2RedeterminationQuery,
          af2_high_value: Agfs::Af2HighValueQuery,
          af2_disk: Agfs::Af2DiskQuery,
          written_reasons: Agfs::WrittenReasonsQuery }
      end
    end
  end
end
