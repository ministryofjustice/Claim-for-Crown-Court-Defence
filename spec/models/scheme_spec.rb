require 'rails_helper'

RSpec.describe Scheme, type: :model do
  it { should have_many(:claims) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
