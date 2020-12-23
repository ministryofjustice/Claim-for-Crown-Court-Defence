# == Schema Information
#
# Table name: certifications
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  certified_by          :string
#  certification_date    :date
#  created_at            :datetime
#  updated_at            :datetime
#  certification_type_id :integer
#

class Certification < ApplicationRecord
  auto_strip_attributes :certified_by, squish: true, nullify: true

  belongs_to :claim, class_name: 'Claim::BaseClaim'
  belongs_to :certification_type

  validates_with CertificationValidator
  validate :at_least_one_boolean_selected

  acts_as_gov_uk_date :certification_date, error_clash_behaviour: :override_with_gov_uk_date_field_error

  def perform_validation?
    true
  end

  private

  def at_least_one_boolean_selected
    return unless claim.is_a?(Claim::AdvocateClaim)

    return if certification_type.present?
    errors[:base] << 'You must select one option on this form'
  end
end
