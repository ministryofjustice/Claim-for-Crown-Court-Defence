# == Schema Information
#
# Table name: chambers
#
#  id              :integer          not null, primary key
#  name            :string
#  supplier_number :string
#  vat_registered  :boolean
#  created_at      :datetime
#  updated_at      :datetime
#  uuid            :uuid
#

class Chamber < ActiveRecord::Base
  auto_strip_attributes :name, :supplier_number, squish: true, nullify: true

  has_many :advocates
  has_many :claims, through: :advocates

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :supplier_number, presence: true, uniqueness: { case_sensitive: false }
end
