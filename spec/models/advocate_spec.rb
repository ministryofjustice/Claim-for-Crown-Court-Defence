require 'rails_helper'

RSpec.describe Advocate, type: :model do
  it { should belong_to(:chamber) }
  it { should have_one(:user) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:user) }

  it { should accept_nested_attributes_for(:user) }

  it { should delegate_method(:email).to(:user) }
end
