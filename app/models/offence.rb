# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string(255)
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Offence < ActiveRecord::Base
  belongs_to :offence_class
  has_many :claims, dependent: :nullify

  validates :offence_class, presence: true
  validates :description, presence: true, uniqueness: { case_sensitive: false }
end
