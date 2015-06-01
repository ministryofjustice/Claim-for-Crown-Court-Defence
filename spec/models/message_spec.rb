# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  subject    :string(255)
#  body       :text
#  claim_id   :integer
#  sender_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Message, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:sender).class_name('User').with_foreign_key('sender_id').inverse_of(:messages_sent) }

  it { should validate_presence_of(:sender_id) }
  it { should validate_presence_of(:claim_id) }
  it { should validate_presence_of(:subject) }
  it { should validate_presence_of(:body) }

  describe '.most_recent_first' do
    let!(:first_message) { create(:message) }
    let!(:second_message) { create(:message) }
    let!(:third_message) { create(:message) }

    it 'returns the message sorted by most recent first' do
      expect(Message.most_recent_first).to eq([third_message, second_message, first_message])
    end
  end
end
