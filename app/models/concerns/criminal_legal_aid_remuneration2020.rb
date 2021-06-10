module CriminalLegalAidRemuneration2020
  extend ActiveSupport::Concern

  def unused_materials_applicable?
    case_type && ['Trial', 'Cracked Trial'].include?(case_type.name) && clar?
  end
end
