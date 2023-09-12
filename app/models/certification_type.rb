# == Schema Information
#
# Table name: certification_types
#
#  id           :integer          not null, primary key
#  name         :string
#  pre_may_2015 :boolean          default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#  roles        :string
#

class CertificationType < ApplicationRecord
  ROLES = %w[agfs lgfs].freeze
  include Roles

  has_many :certifications

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :pre_may_2015,              -> { where(pre_may_2015: true) }
  scope :post_may_2015,             -> { where(pre_may_2015: false) }
end
