# == Schema Information
#
# Table name: case_types
#
#  id                      :integer          not null, primary key
#  name                    :string
#  is_fixed_fee            :boolean
#  created_at              :datetime
#  updated_at              :datetime
#  requires_cracked_dates  :boolean
#  requires_trial_dates    :boolean
#  allow_pcmh_fee_type     :boolean          default(FALSE)
#  requires_maat_reference :boolean          default(FALSE)
#  requires_retrial_dates  :boolean          default(FALSE)
#  roles                   :string
#  fee_type_code           :string
#

class CaseType < ActiveRecord::Base
  ROLES = %w( lgfs agfs interim ).freeze
  include Roles

  auto_strip_attributes :name, squish: true, nullify: true

  default_scope -> { order(name: :asc) }

  scope :fixed_fee,               -> { where(is_fixed_fee: true) }
  scope :graduated_fees,          -> { where(fee_type_code: Fee::GraduatedFeeType.pluck(:unique_code)) }
  scope :requires_cracked_dates,  -> { where(requires_cracked_dates: true) }
  scope :requires_trial_dates,    -> { where(requires_trial_dates: true) }
  scope :requires_retrial_dates,  -> { where(requires_retrial_dates: true) }

  def self.by_type(type)
    CaseType.where(name: type).first
  end

  def self.ids_by_types(*args)
    case_types = CaseType.where('name in (?)', args)
    case_types.map(&:id)
  end

  def graduated_fee_type
    return nil if fee_type_code.nil?
    Fee::GraduatedFeeType.by_unique_code(fee_type_code)
  end

  def fixed_fee_type
    return nil if fee_type_code.nil?
    Fee::FixedFeeType.by_unique_code(fee_type_code)
  end

  def is_graduated_fee?
    graduated_fee_type.nil? ? false : true
  end

  # We do not need the D.O.B of the defendant to be requested for case type "Breach of Crown Court order"
  def requires_defendant_dob?
    fee_type_code != 'FXCBR'
  end

  # CCR stores billing scenarios that map to
  # to CCCD case types, except "Hearing subsequent to sentence".
  # Passed to CCR via API for calculation of fees.
  #
  def bill_scenario
    @bill_scenario ||= Settings.ccr_bill_scenario_mappings.to_h.select do |_k, v|
      v.casecmp(name) == 0
    end.keys.first
  end
end
