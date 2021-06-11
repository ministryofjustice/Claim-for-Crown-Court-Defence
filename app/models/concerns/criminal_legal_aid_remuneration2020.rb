module CriminalLegalAidRemuneration2020
  extend ActiveSupport::Concern

  def unused_materials_applicable?
    %w[GRTRL GRRAK].include?(case_type&.fee_type_code) && clar?
  end
end
