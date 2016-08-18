# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

class Location < ActiveRecord::Base
  auto_strip_attributes :name, squish: true, nullify: true

  has_many :case_workers

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def to_s
    name
  end
end
