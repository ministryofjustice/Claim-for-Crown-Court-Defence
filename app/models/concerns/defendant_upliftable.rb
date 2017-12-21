# Extends fee types by adding methods providing
# information and data on those fees types are considered
# to be "defendant uplifts"
#
# "defendant uplifts" are fees of a type
# that are applicable when claiming remuneration
# for work done in relation to additional defendants
# on a case
#
module DefendantUpliftable
  extend ActiveSupport::Concern

  class_methods do
    DEFENDANT_UPLIFT_MAPPINGS = {
      BASAF: 'MISAU', # Standard appearance fee uplift
      MIAPH: 'MIAHU', # Abuse of process hearings (half day uplift)
      MIAPW: 'MIAWU', # Abuse of process hearings (whole day uplift)
      MIADC1: 'MIADC3', # Application to dismiss a charge (half day uplift)
      MIADC2: 'MIADC4', # Application to dismiss a charge (whole day uplift)
      MIDTH: 'MIDHU', # Confiscation hearings (half day uplift)
      MIDTW: 'MIDWU', # Confiscation hearings (whole day uplift)
      MIDSE: 'MIDSU', # Deferred sentence hearings uplift
      MIAEH: 'MIEHU', # Hearings relating to admissibility of evidence (half day uplift)
      MIAEW: 'MIEWU', # Hearings relating to admissibility of evidence (whole day uplift)
      MIHDH: 'MIHHU', # Hearings relating to disclosure (half day uplift)
      MIHDW: 'MIHWU', # Hearings relating to disclosure (whole day uplift)
      MIPPC: 'MIPCU', # Paper plea & case management uplift
      MIPCH: 'MICHU', # Proceeds of crime hearings (half day uplift)
      MIPCW: 'MICHW', # Proceeds of crime hearings (whole day uplift)
      MIPIH1: 'MIPIU3', # Public interest immunity hearings (half day uplift)
      MIPIH2: 'MIPIH4', # Public interest immunity hearings (whole day uplift)
      MISHR: 'MISHU', # Sentence hearings uplift
      MITNP: 'MITNU', # Trial not proceed uplift
      MIUAV1: 'MIUAV3', # Unsuccessful application to vacate a guilty plea (half day uplift)
      MIUAV2: 'MIUAV4', # Unsuccessful application to vacate a guilty plea (whole day uplift)
    }.with_indifferent_access.freeze

    ORPHAN_DEFENDANT_UPLIFTS = %w[BANDR FXNDR].freeze

    def defendant_uplifts
      where(unique_code: defendant_uplift_unique_codes)
    end

    def defendant_uplift_unique_codes
      DEFENDANT_UPLIFT_MAPPINGS.values + ORPHAN_DEFENDANT_UPLIFTS
    end
  end

  included do
    def defendant_uplift?
      unique_code.in?(self.class.defendant_uplift_unique_codes)
    end
  end
end
