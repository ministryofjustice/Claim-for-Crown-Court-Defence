# == Schema Information
#
# Table name: defendants
#
#  id                               :integer          not null, primary key
#  first_name                       :string(255)
#  middle_name                      :string(255)
#  last_name                        :string(255)
#  date_of_birth                    :datetime
#  representation_order_date        :datetime
#  order_for_judicial_apportionment :boolean
#  maat_reference                   :string(255)
#  claim_id                         :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#

class Defendant < ActiveRecord::Base
  belongs_to :claim

  validates :claim, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :maat_reference, presence: true, uniqueness: { case_sensitive: false, scope: :claim_id }

  before_save { |defendant| defendant.maat_reference = defendant.maat_reference.upcase }

  def name
    [first_name, last_name].join(' ')
  end
end
