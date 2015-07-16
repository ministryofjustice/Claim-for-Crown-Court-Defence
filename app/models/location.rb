# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Location < ActiveRecord::Base
  has_many :case_workers, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def to_s
    name
  end
end
