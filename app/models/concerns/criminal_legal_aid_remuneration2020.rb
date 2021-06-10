module CriminalLegalAidRemuneration2020
  extend ActiveSupport::Concern

  def unused_materials_applicable?
    clar? && ['Trial', 'Cracked Trial'].include?(case_type.name)
  end
end
