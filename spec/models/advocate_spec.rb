require 'rails_helper'

RSpec.describe Advocate, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
end
