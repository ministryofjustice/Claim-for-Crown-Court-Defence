require 'rails_helper'

RSpec.describe Claims::UserMessages, type: :model do
  let!(:claim) { create(:submitted_claim) }

  describe '#has_unread_messages?' do
    context 'when unread messages present' do
      before { create(:message, claim: claim) }

      it 'has unread messages' do
        expect(claim).to have_unread_messages
      end
    end

    context 'when no unread messages present' do
      before do
        create(:message)
        UserMessageStatus.first.update_column(:read, true)
      end

      it 'does not have unread messages' do
        expect(claim).to_not have_unread_messages
      end
    end

    context 'when no messages present' do
      it 'does not have unread messages' do
        expect(claim).to_not have_unread_messages
      end
    end
  end

  describe '#has_read_messages?' do
    context 'when read messages present' do
      before do
        create(:message, claim: claim)
        UserMessageStatus.first.update_column(:read, true)
      end

      it 'has read messages' do
        expect(claim).to have_read_messages
      end
    end

    context 'when no read messages present' do
      before do
        create(:message)
      end

      it 'does not have read messages' do
        expect(claim).to_not have_read_messages
      end
    end

    context 'when no messages present' do
      it 'does not have read messages' do
        expect(claim).to_not have_read_messages
      end
    end
  end

  describe '#unread_messages' do
    let(:message_1) { create(:message, claim: claim) }
    let(:message_2) { create(:message, claim: claim) }

    context 'when unread messages present' do
      before do
        message_2.user_message_statuses.each { |status| status.update_column(:read, true) }
      end

      it 'returns unread messages' do
        expect(claim.unread_messages).to match_array([message_1])
      end
    end

    context 'when no unread messages present' do
      before do
        UserMessageStatus.all.each do |status|
          status.update_column(read: true)
        end
      end

      it 'does not return any messages' do
        expect(claim.unread_messages).to be_empty
      end
    end

    context 'when no messages present' do
      it 'does not return any messages' do
        expect(claim.unread_messages).to be_empty
      end
    end
  end

  describe '#read_messages' do
    let(:message_1) { create(:message, claim: claim) }
    let(:message_2) { create(:message, claim: claim) }

    context 'when read messages present' do
      before do
        message_2.user_message_statuses.each { |status| status.update_column(:read, true) }
      end

      it 'returns read messages' do
        expect(claim.read_messages).to match_array([message_2])
      end
    end

    context 'when no read messages present' do
      it 'does not return any messages' do
        expect(claim.read_messages).to be_empty
      end
    end

    context 'when no messages present' do
      it 'does not return any messages' do
        expect(claim.read_messages).to be_empty
      end
    end
  end

  describe '#unread_messages_for' do
    let(:user) { claim.advocate.user }
    let(:message_1) { create(:message, claim: claim) }
    let(:message_2) { create(:message, claim: claim) }

    context 'when unread messages present' do
      before do
        message_2.user_message_statuses.where(user_id: user.id).each { |status| status.update_column(:read, true) }
      end

      it 'returns unread messages for user' do
        expect(claim.unread_messages_for(user)).to match_array([message_1])
      end
    end

    context 'when no unread messages present' do
      before do
        UserMessageStatus.where(user_id: user.id).each do |status|
          status.update_column(read: true)
        end
      end

      it 'does not return any messages' do
        expect(claim.unread_messages_for(user)).to be_empty
      end
    end

    context 'when no messages present' do
      it 'does not return any messages' do
        expect(claim.unread_messages_for(user)).to be_empty
      end
    end
  end

  describe '#read_messages_for' do
    let(:user) { claim.advocate.user }
    let(:message_1) { create(:message, claim: claim) }
    let(:message_2) { create(:message, claim: claim) }

    context 'when read messages present' do
      before do
        message_2.user_message_statuses.where(user_id: user.id).each { |status| status.update_column(:read, true) }
      end

      it 'returns read messages' do
        expect(claim.read_messages).to match_array([message_2])
      end
    end

    context 'when no read messages present' do
      it 'does not return any messages' do
        expect(claim.read_messages).to be_empty
      end
    end

    context 'when no messages present' do
      it 'does not return any messages' do
        expect(claim.read_messages).to be_empty
      end
    end
  end

  describe '#has_unread_messages_for?' do
    let(:user) { claim.advocate.user }

    context 'when unread messages present' do
      before { create(:message, claim: claim) }

      it 'has unread messages' do
        expect(claim).to have_unread_messages_for(user)
      end
    end

    context 'when no unread messages present' do
      before do
        create(:message)
        UserMessageStatus.first.update_column(:read, true)
      end

      it 'does not have unread messages' do
        expect(claim).to_not have_unread_messages_for(user)
      end
    end

    context 'when no messages present' do
      it 'does not have unread messages' do
        expect(claim).to_not have_unread_messages_for(user)
      end
    end
  end

  describe '#has_read_messages_for?' do
    let(:user) { claim.advocate.user }

    context 'when read messages present' do
      before do
        create(:message, claim: claim)
        UserMessageStatus.first.update_column(:read, true)
      end

      it 'has read messages' do
        expect(claim).to have_read_messages_for(user)
      end
    end

    context 'when no read messages present' do
      before do
        create(:message)
      end

      it 'does not have read messages' do
        expect(claim).to_not have_read_messages_for(user)
      end
    end

    context 'when no messages present' do
      it 'does not have read messages' do
        expect(claim).to_not have_read_messages_for(user)
      end
    end
  end
end
