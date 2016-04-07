# == Schema Information
#
# Table name: certification_types
#
#  id           :integer          not null, primary key
#  name         :string
#  pre_may_2015 :boolean          default(FALSE)
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

RSpec.describe CertificationType, type: :model do
  it_behaves_like 'roles', CertificationType, CertificationType::ROLES

  it { should have_many(:certifications) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).with_message('Certification type name has already been taken')  }
end
