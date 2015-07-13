# == Schema Information
#
# Table name: schemes
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Scheme < ActiveRecord::Base
  has_many :claims

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :start_date, presence: true, uniqueness: true
  validates :end_date, uniqueness: true, allow_nil: true
end
