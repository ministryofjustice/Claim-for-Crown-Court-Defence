# == Schema Information
#
# Table name: offences
#
#  id               :integer          not null, primary key
#  description      :string
#  offence_class_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class Offence < ActiveRecord::Base
  belongs_to :offence_class
  has_many :claims, dependent: :nullify

  validates :offence_class, presence: true
  validates :description, presence: true

  scope :unique_name, -> { select('DISTINCT(description)') }

  def as_json(options = {})
    super((options || {}).merge({
      methods: [:offence_class]
    }))
  end
end
