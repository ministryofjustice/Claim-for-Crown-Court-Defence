require 'rails_helper'

RSpec.describe User, type: :model do
  it { should belong_to(:persona) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should have_many(:messages_sent).class_name('Message').with_foreign_key('sender_id') }

  it { should delegate_method(:claims).to(:persona) }

  describe '#name' do
    subject { create(:user) }

    it 'returns the first and last names' do
      expect(subject.name).to eq("#{subject.first_name} #{subject.last_name}")
    end
  end
end
