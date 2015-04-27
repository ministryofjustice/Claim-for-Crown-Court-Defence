require 'rails_helper'

RSpec.describe Chamber, type: :model do
  it { should have_many(:advocates) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:supplier_no) }
  it { should validate_uniqueness_of(:supplier_no) }
end
