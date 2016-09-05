# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  body                    :text
#  claim_id                :integer
#  sender_id               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

require 'rails_helper'

RSpec.describe Message, type: :model do
  it { should belong_to(:claim) }
  it { should belong_to(:sender).class_name('User').with_foreign_key('sender_id').inverse_of(:messages_sent) }
  it { should have_many(:user_message_statuses) }

  it { should validate_presence_of(:sender).with_message('Message sender cannot be blank') }
  it { should validate_presence_of(:claim_id).with_message('Message claim_id cannot be blank') }
  it { should validate_presence_of(:body).with_message('Message body cannot be blank') }

  it { should have_attached_file(:attachment) }

  it do
     should validate_attachment_content_type(:attachment).
       allowing('application/pdf',
                'application/msword',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'application/vnd.oasis.opendocument.text',
                'text/rtf',
                'application/rtf',
                'image/jpeg',
                'image/png',
                'image/tiff',
                'image/bmp',
                'image/x-bitmap').
       rejecting('text/plain',
                 'text/html')
  end

  it { should validate_attachment_size(:attachment).in(0.megabytes..20.megabytes) }

  describe '.for' do
    let(:message) { create(:message) }
    let(:claim) { message.claim }
    let(:user) { message.sender }

    it 'returns the messaages for the user' do
      expect(Message.for(user)).to eq([message])
    end

    it 'returns the messaages for the claim' do
      expect(Message.for(claim)).to eq([message])
    end
  end

  describe '.most_recent_first' do
    let!(:first_message) { create(:message) }
    let!(:second_message) { create(:message) }
    let!(:third_message) { create(:message) }

    it 'returns the message sorted by most recent first' do
      expect(Message.most_recent_first).to eq([third_message, second_message, first_message])
    end
  end

  describe 'user status messages' do
    subject { create(:message) }

    before do
      case_worker = create(:case_worker)
      subject.claim.case_workers << case_worker
    end

    it 'creates unread user message status for all relevant users' do
      subject.reload
      expect(UserMessageStatus.where(read: false).count).to eq(2)
    end
  end


  context 'automotic state change of claim on message creation' do

    let(:claim)     { create :part_authorised_claim }
    let(:user)      { create :user }

    it 'should change claim state from allocated to redetermination if claim_action set to apply for redetermination' do
      claim.messages.build(sender: user, body: 'xxxxx', claim_action: 'Apply for redetermination')
      claim.save
      expect(claim.state).to eq 'redetermination'
    end

    it 'should change claim state from allocated to await_written_reasons if claim_action set to request written reasons' do
      claim.messages.build(sender: user, body: 'xxxxx', claim_action: 'Request written reasons')
      claim.save
      expect(claim.state).to eq 'awaiting_written_reasons'
    end

    it 'should change claim state from if claim_action not set' do
      claim.messages.build( sender: user, body: 'xxxxx')
      claim.save
      expect(claim.state).to eq 'part_authorised'
    end
  end

  context 'process written reasons' do
    let(:claim)     { create :part_authorised_claim }
    let(:user)      { create :user }

    it 'should change claim state back to what it was before, if written reasons submitted' do
      claim.messages.build(sender: user, body: 'xxxxx', claim_action: 'Request written reasons')
      claim.messages.first.written_reasons_submitted = '1'
      claim.save
      claim.reload
      expect(claim.claim_state_transitions.reorder(created_at: :asc).map(&:event)).to eq( [ nil, 'submit', 'allocate', 'authorise_part', 'await_written_reasons', 'authorise_part' ] )
      expect(claim.state).to eq 'part_authorised'
    end
  end
end
