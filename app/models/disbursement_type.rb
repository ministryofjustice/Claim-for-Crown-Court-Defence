# == Schema Information
#
# Table name: disbursement_types
#
#  id          :integer          not null, primary key
#  name        :string
#  created_at  :datetime
#  updated_at  :datetime
#  deleted_at  :datetime
#  unique_code :string
#

class DisbursementType < ActiveRecord::Base
  include SoftlyDeletable

  default_scope -> { order(name: :asc) }

  auto_strip_attributes :name, squish: true, nullify: true

  has_many :disbursements, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false, message: 'A disbursement type of this name already exists' }
  validates :unique_code, presence: true, uniqueness: { case_sensitive: false, message: 'A disbursement type with this unique code already exists' }
end
