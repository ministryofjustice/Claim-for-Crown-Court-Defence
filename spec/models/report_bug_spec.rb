require 'rails_helper'

RSpec.describe BugReport, type: :model do
  it { should validate_presence_of(:event) }
  it { should validate_presence_of(:outcome) }

  describe '#initialize' do
    subject do
      BugReport.new(
        email: 'example@example.com',
        event: 'lorem',
        outcome: 'ipsum',
        user_agent: 'Firefox',
        referrer: '/index'
      )
    end

    it 'sets the email' do
      expect(subject.email).to eq('example@example.com')
    end

    it 'sets the event' do
      expect(subject.event).to eq('lorem')
    end

    it 'sets the outcome' do
      expect(subject.outcome).to eq('ipsum')
    end

    it 'sets the user_agent' do
      expect(subject.user_agent).to eq('Firefox')
    end

    it 'sets the referrer' do
      expect(subject.referrer).to eq('/index')
    end
  end

  describe '#save' do
    subject do
      BugReport.new(
        email: 'example@example.com',
        event: 'lorem',
        outcome: 'ipsum',
        user_agent: 'Firefox',
        referrer: '/index'
      )
    end

    before do
      allow(ZendeskAPI::Ticket).to receive(:create!).and_return(true)
    end

    context 'when valid' do
      it 'creates zendesk ticket and returns true' do
        expect(subject.save).to eq(true)
      end
    end

    context 'when invalid' do
      it 'returns false' do
        subject.event = nil
        subject.outcome = nil
        expect(subject.save).to eq(false)
      end
    end
  end
end
