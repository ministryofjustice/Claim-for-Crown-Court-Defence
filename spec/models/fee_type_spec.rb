# == Schema Information
#
# Table name: fee_types
#
#  id              :integer          not null, primary key
#  description     :string(255)
#  code            :string(255)
#  fee_category_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe FeeType, type: :model do
  it { should belong_to(:fee_category) }
  it { should have_many(:fees) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:fee_category) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:description) }
end
