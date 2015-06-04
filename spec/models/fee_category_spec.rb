# == Schema Information
#
# Table name: fee_categories
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  abbreviation :string(255)
#

require 'rails_helper'

RSpec.describe FeeCategory, type: :model do
  it { should have_many(:fee_types) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:abbreviation) }
  it { should validate_uniqueness_of(:abbreviation) }  
end
