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
#  parent_id               :integer
#  grad_fee_code           :string
#

class CaseType < ActiveRecord::Base
  ROLES = %w{ lgfs agfs }
  include Roles
  
  auto_strip_attributes :name, squish: true, nullify: true

  has_many :children, class_name: CaseType, foreign_key: :parent_id
  belongs_to :parent, class_name: CaseType, foreign_key: :parent_id

  default_scope -> { order(parent_id: :desc, name: :asc) }

  scope :top_levels,              -> { where(parent_id: nil) }
  scope :fixed_fee,               -> { where(is_fixed_fee: true) }
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
    return nil if grad_fee_code.nil?
    Fee::GraduatedFeeType.by_code(grad_fee_code)
  end

  def is_hearing?
    name == 'Hearing subsequent to sentence'
  end
end
