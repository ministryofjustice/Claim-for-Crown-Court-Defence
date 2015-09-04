# == Schema Information
#
# Table name: case_types
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  is_fixed_fee           :boolean
#  created_at             :datetime
#  updated_at             :datetime
#  requires_cracked_dates :boolean
#  requires_trial_dates   :boolean
#

class CaseType < ActiveRecord::Base

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

  
end
