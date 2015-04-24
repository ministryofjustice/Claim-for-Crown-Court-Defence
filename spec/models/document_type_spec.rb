require 'rails_helper'

RSpec.describe DocumentType, type: :model do
  it { should have_many(:documents) }
  it { should validate_presence_of(:description) }
  it { should validate_uniqueness_of(:description) }
end
