# == Schema Information
#
# Table name: certification_types
#
#  id                               :integer          not null, primary key
#  name                             :string
#  created_at                       :datetime
#  updated_at                       :datetime
#

require 'rails_helper'

RSpec.describe CertificationType, type: :model do
  it { should have_many(:certifications) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
