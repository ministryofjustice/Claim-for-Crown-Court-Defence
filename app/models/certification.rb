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

  attr_accessor :additional_fees

  validates_with CertificationValidator

  def perform_validation?
    true
  end
end
