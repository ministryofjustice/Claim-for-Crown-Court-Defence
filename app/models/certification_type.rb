# == Schema Information
#
# Table name: certification_types
#
#  id                               :integer          not null, primary key
#  name                             :string
#  created_at                       :datetime
#  updated_at                       :datetime
#

class CertificationType < ActiveRecord::Base
  has_many :certification

  scope :pre_may_2015,              -> { where('id > ?', 1) }
  scope :post_may_2015,             -> { where( id: 1) }

end
