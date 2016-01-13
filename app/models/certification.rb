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

  has_one :certification_type

  validates :certification_type_id, presence: true, inclusion: { in: CertificationType.pluck(:id) }

  validate :certification_type_id_valid
  validate :certification_date_valid
  validate :certified_by_valid

  acts_as_gov_uk_date :certification_date

  private

  def certification_type_id_valid
    errors[:base] << "You must select one option on this form" if certification_type_id.blank?
  end

  def certification_date_valid
    errors[:base] << 'Certification date cannot be blank' if certification_date.blank?
  end

  def certified_by_valid
    errors[:base] << 'Certified by cannot be blank' if certified_by.blank?
  end

end
