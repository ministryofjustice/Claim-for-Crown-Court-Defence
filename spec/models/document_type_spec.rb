# == Schema Information
#
# Table name: document_types
#
#  id          :integer          not null, primary key
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe DocumentType, type: :model do
  it { should have_many(:documents) }
  it { should validate_presence_of(:description) }
  it { should validate_uniqueness_of(:description) }
end
