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
  ROLES = %w{ lgfs agfs }
  include Roles

  auto_strip_attributes :name, squish: true, nullify: true

  default_scope -> { order(name: :asc) }

  scope :fixed_fee,               -> { where(is_fixed_fee: true) }
  scope :requires_cracked_dates,  -> { where(requires_cracked_dates: true) }
  scope :requires_trial_dates,    -> { where(requires_trial_dates: true) }

  def self.by_type(type)
    CaseType.where(name: type).first
  end

  def self.ids_by_types(*args)
    case_types = CaseType.where('name in (?)', args)
    case_types.map(&:id)
  end

  def graduated_fee_type
    return nil if fee_type_code.nil?
    Fee::GraduatedFeeType.by_code(fee_type_code)
  end

  def fixed_fee_type
    return nil if fee_type_code.nil?
    Fee::FixedFeeType.by_code(fee_type_code)
  end
end
