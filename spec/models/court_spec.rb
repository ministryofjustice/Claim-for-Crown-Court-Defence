# == Schema Information
#
# Table name: courts
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  court_type :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Court, type: :model do
  it { should have_many(:claims) }

  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code).with_message('Court code must be unique') }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).with_message('Court name must be unique') }
  it { should validate_presence_of(:court_type) }
  it { should validate_inclusion_of(:court_type).in_array(%w( crown magistrate )) }
end
