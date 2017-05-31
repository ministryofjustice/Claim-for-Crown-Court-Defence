# == Schema Information
#
# Table name: super_admins
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class SuperAdmin < ActiveRecord::Base
  has_one :user, as: :persona, inverse_of: :persona, dependent: :destroy
  validates :user, presence: true

  default_scope { includes(:user) }

  accepts_nested_attributes_for :user

  delegate :email, to: :user
  delegate :first_name, to: :user
  delegate :last_name, to: :user
  delegate :name, to: :user
end
