module CCR
  module Fee
    class MiscFeeAdapter < BaseFeeAdapter
      MISC_FEE_BILL_MAPPINGS = {
        BAPCM: zip(%w[AGFS_MISC_FEES AGFS_PLEA]), # Plea & Case management hearing (basic fee)
        BASAF: zip(%w[AGFS_MISC_FEES AGFS_STD_APPRNC]), # Standard appearance fee (basic fee)
        BACAV: zip(%w[AGFS_MISC_FEES AGFS_CONFERENCE]), # Conferences and views (basic fee)
        FXCON: zip(%w[AGFS_MISC_FEES AGFS_CONTEMPT]), # Contempt (fixed fee)
        FXSAF: zip(%w[AGFS_MISC_FEES AGFS_STD_APPRNC]), # Standard Appearance fee (fixed fee)
        MIAHU: zip(%w[AGFS_MISC_FEES TBC]), # Abuse of process hearings (half day uplift)
        MIAPH: zip(%w[AGFS_MISC_FEES AGFS_ABS_PRC_HF]), # Abuse of process hearings (half day)
        MIAWU: zip(%w[AGFS_MISC_FEES TBC]), # Abuse of process hearings (whole day uplift)
        MIAPW: zip(%w[AGFS_MISC_FEES AGFS_ABS_PRC_WL]), # Abuse of process hearings (whole day)
        MISAF: zip(%w[AGFS_MISC_FEES AGFS_ADJOURNED]), # Adjourned appeals
        MIADC3: zip(%w[AGFS_MISC_FEES TBC]), # Application to dismiss a charge (half day uplift)
        MIADC1: zip(%w[AGFS_MISC_FEES AGFS_DMS_DY2_HF]), # Application to dismiss a charge (half day)
        MIADC4: zip(%w[AGFS_MISC_FEES TBC]), # Application to dismiss a charge (whole day uplift)
        MIADC2: zip(%w[AGFS_MISC_FEES AGFS_DMS_DY2_WL]), # Application to dismiss a charge (whole day)
        MIUPL: zip(%w[TBC TBC]), # Case uplift ***CCLF-applicable-only***
        MIDHU: zip(%w[AGFS_MISC_FEES TBC]), # Confiscation hearings (half day uplift)
        MIDTH: zip(%w[AGFS_MISC_FEES AGFS_CONFISC_HF]), # Confiscation hearings (half day)
        MIDWU: zip(%w[AGFS_MISC_FEES TBC]), # Confiscation hearings (whole day uplift)
        MIDTW: zip(%w[AGFS_MISC_FEES AGFS_CONFISC_WL]), # Confiscation hearings (whole day)
        MICJA: zip(%w[OTHER COST_JUDGE_FEE]), # Costs judge application ***CCLF-applicable-only***
        MICJP: zip(%w[OTHER COST_JUD_EXP]), # Costs judge preparation ***CCLF-applicable-only***
        MIDSE: zip(%w[AGFS_MISC_FEES AGFS_DEF_SEN_HR]), # Deferred sentence hearings
        MIDSU: zip(%w[AGFS_MISC_FEES TBC]), # Deferred sentence hearings uplift
        MIEVI: zip(%w[EVID_PROV_FEE EVID_PROV_FEE]), # Evidence provision fee ***CCLF-applicable-only***
        MIEHU: zip(%w[AGFS_MISC_FEES TBC]), # Hearings relating to admissibility of evidence (half day uplift)
        MIAEH: zip(%w[AGFS_MISC_FEES AGFS_ADM_EVD_HF]), # Hearings relating to admissibility of evidence (half day)
        MIEWU: zip(%w[AGFS_MISC_FEES TBC]), # Hearings relating to admissibility of evidence (whole day uplift)
        MIAEW: zip(%w[AGFS_MISC_FEES AGFS_ADM_EVD_WL]), # Hearings relating to admissibility of evidence (whole day)
        MIHHU: zip(%w[AGFS_MISC_FEES TBC]), # Hearings relating to disclosure (half day uplift)
        MIHDH: zip(%w[AGFS_MISC_FEES AGFS_DISC_HALF]), # Hearings relating to disclosure (half day)
        MIHWU: zip(%w[AGFS_MISC_FEES TBC]), # Hearings relating to disclosure (whole day uplift)
        MIHDW: zip(%w[AGFS_MISC_FEES AGFS_DISC_FULL]), # Hearings relating to disclosure (whole day)
        MINBR: zip(%w[AGFS_MISC_FEES AGFS_NOTING_BRF]), # Noting brief fee
        MIPPC: zip(%w[AGFS_MISC_FEES AGFS_PAPER_PLEA]), # Paper plea & case management
        MIPCU: zip(%w[AGFS_MISC_FEES TBC]), # Paper plea & case management uplift
        MICHU: zip(%w[AGFS_MISC_FEES TBC]), # Proceeds of crime hearings (half day uplift)
        MIPCH: zip(%w[AGFS_MISC_FEES AGFS_CONFISC_HF]), # Proceeds of crime hearings (half day) **** DUPLICATE - sames as confiscation hearings above****
        MICHW: zip(%w[AGFS_MISC_FEES TBC]), # Proceeds of crime hearings (whole day uplift)
        MIPCW: zip(%w[AGFS_MISC_FEES AGFS_CONFISC_WL]), # Proceeds of crime hearings (whole day) **** DUPLICATE - sames as confiscation hearings above****
        MIPIU3: zip(%w[AGFS_MISC_FEES TBC]), # Public interest immunity hearings (half day uplift)
        MIPIH1: zip(%w[AGFS_MISC_FEES AGFS_PI_IMMN_HF]), # Public interest immunity hearings (half day)
        MIPIH4: zip(%w[AGFS_MISC_FEES TBC]), # Public interest immunity hearings (whole day uplift)
        MIPIH2: zip(%w[AGFS_MISC_FEES AGFS_PI_IMMN_WL]), # Public interest immunity hearings (whole day)
        MIRNF: zip(%w[AGFS_MISC_FEES AGFS_NOVELISSUE]), # Research of very unusual or novel factual issue
        MIRNL: zip(%w[AGFS_MISC_FEES AGFS_NOVEL_LAW]), # Research of very unusual or novel point of law
        MISHR: zip(%w[AGFS_MISC_FEES AGFS_SENTENCE]), # Sentence hearings
        MISHU: zip(%w[AGFS_MISC_FEES TBC]), # Sentence hearings uplift
        MISPF: zip(%w[AGFS_MISC_FEES AGFS_SPCL_PREP]), # Special preparation fee - AGFS only version
        # MISPF: zip(%w[FEE_SUPPLEMENT SPECIAL_PREP]), # TODO: Special preparation fee - LGFS only version - need to apply fee type role logic
        MISAU: zip(%w[AGFS_MISC_FEES TBC]), # Standard appearance fee uplift
        MITNP: zip(%w[AGFS_MISC_FEES AGFS_NOT_PRCD]), # Trial not proceed
        MITNU: zip(%w[AGFS_MISC_FEES TBC]), # Trial not proceed uplift
        MIUAV3: zip(%w[AGFS_MISC_FEES TBC]), # Unsuccessful application to vacate a guilty plea (half day uplift)
        MIUAV1: zip(%w[AGFS_MISC_FEES AGFS_UN_VAC_HF]), # Unsuccessful application to vacate a guilty plea (half day)
        MIUAV4: zip(%w[AGFS_MISC_FEES TBC]), # Unsuccessful application to vacate a guilty plea (whole day uplift)
        MIUAV2: zip(%w[AGFS_MISC_FEES AGFS_UN_VAC_WL]), # Unsuccessful application to vacate a guilty plea (whole day)
        MIWPF: zip(%w[AGFS_MISC_FEES AGFS_WSTD_PREP]), # Wasted preparation fee
        MIWOA: zip(%w[AGFS_MISC_FEES AGFS_WRTN_ORAL]) # Written / oral advice
      }.freeze

      def claimed?
        maps? && charges?
      end

      private

      def bill_mappings
        MISC_FEE_BILL_MAPPINGS
      end

      def bill_key
        object.fee_type.unique_code.to_sym
      end

      def charges?
        object.amount.positive? || object.quantity.positive? || object.rate.positive?
      end
    end
  end
end
