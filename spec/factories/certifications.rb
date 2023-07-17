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

FactoryBot.define do
  factory :certification do
    certification_type
    certified_by        { 'Stepriponikas Bonstart' }
    certification_date  { Time.zone.today }
  end
end
