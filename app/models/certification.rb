# == Schema Information
#
# Table name: certifications
#
#  id                               :integer          not null, primary key
#  claim_id                         :integer
#  certification_type_id            :integer
#  certified_by                     :string
#  certification_date               :date
#  created_at                       :datetime
#  updated_at                       :datetime
#

class Certification < ActiveRecord::Base
  auto_strip_attributes :certified_by, squish: true, nullify: true

  belongs_to :claim
  belongs_to :certification_type

  validates :certification_type_id, presence: true
  validates :certification_date, presence: true
  validates :certified_by, presence: true

  validate :at_least_one_boolean_selected

  acts_as_gov_uk_date :certification_date

  private

  def at_least_one_boolean_selected
    values = attributes.slice(%w(main_hearing notified_court attended_pcmh attended_first_hearing previous_advocate_notified_court fixed_fee_case)).values
    unless values.uniq.include?(true)
      errors[:base] << 'You must select one option on this form'
    end
  end
end
