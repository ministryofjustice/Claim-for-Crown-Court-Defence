# == Schema Information
#
# Table name: disbursement_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class DisbursementType < ActiveRecord::Base
  include SoftlyDeletable

  default_scope -> { order(name: :asc) }

  auto_strip_attributes :name, squish: true, nullify: true

  has_many :disbursements, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

end
