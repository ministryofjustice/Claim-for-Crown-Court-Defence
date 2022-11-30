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

require 'rails_helper'

RSpec.describe Certification do
  subject(:certification) { build(:certification, certification_type:, claim:) }

  let!(:certification_type) { create(:certification_type) }
  let(:claim) { build(:claim) }

  it { is_expected.to belong_to(:claim) }
  it { is_expected.to belong_to(:certification_type) }

  it { is_expected.to validate_with(CertificationValidator) }
end
