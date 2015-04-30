require 'rails_helper'

RSpec.describe Advocate, type: :model do
  it { should belong_to(:chamber) }
  it { should have_one(:user) }
  it { should have_many(:claims) }

  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:user) }

  it { should accept_nested_attributes_for(:user) }

  it { should delegate_method(:email).to(:user) }

  describe '#name' do
    subject { create(:advocate) }

    it 'returns the first and last names' do
      expect(subject.name).to eq("#{subject.first_name} #{subject.last_name}")
    end
  end
end
