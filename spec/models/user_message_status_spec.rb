# == Schema Information
#
# Table name: user_message_statuses
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  message_id :integer
#  read       :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe UserMessageStatus do
  it { should belong_to(:user) }
  it { should belong_to(:message) }

  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:message) }

  describe '.marked_as_read' do
    let!(:read_statuses) { create_list(:user_message_status, 5, :read, :unpersisted) }
    let!(:unread_statuses) { create_list(:user_message_status, 5, :unpersisted) }

    it 'only returns read statuses' do
      expect(UserMessageStatus.marked_as_read.pluck(:read).uniq).to match_array([true])
    end
  end

  describe '.not_marked_as_read' do
    let!(:read_statuses) { create_list(:user_message_status, 5, :read, :unpersisted) }
    let!(:unread_statuses) { create_list(:user_message_status, 5, :unpersisted) }

    it 'only returns unread statuses' do
      expect(UserMessageStatus.not_marked_as_read.pluck(:read).uniq).to match_array([false])
    end
  end

  describe '.for' do
    let!(:user) { create(:user) }

    before do
      create(:user_message_status, user_id: user.id)
    end

    it 'only returns the statuses for the given user' do
      expect(UserMessageStatus.for(user).pluck(:user_id).uniq).to match_array([user.id])
    end
  end
end
