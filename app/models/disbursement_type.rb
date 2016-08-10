# == Schema Information
#
# Table name: disbursement_types
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

class DisbursementType < ActiveRecord::Base
  auto_strip_attributes :name, squish: true, nullify: true

  has_many :disbursements, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  # Temporal as there are claims using this disbursement type and we can't
  # reassign those to another one, so for new claims we hide this type from dropdowns
  # and API but old ones will continue to work and validate.
  # Revisit this in some weeks once all old claims have been processed.
  #
  def self.allowable_types
    all.where.not(name: 'Travel costs')
  end
end
