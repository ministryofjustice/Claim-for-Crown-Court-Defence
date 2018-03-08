require 'rails_helper'

RSpec.describe FeeCategory, type: :model do
  it { should have_many(:fee_bands) }
end
