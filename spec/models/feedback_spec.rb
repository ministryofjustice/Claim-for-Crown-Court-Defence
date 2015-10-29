require 'rails_helper'

RSpec.describe Feedback, type: :model do
  it { should validate_inclusion_of(:rating).in_array(('1'..'5').to_a) }

  describe '#initialize' do
    subject do
      Feedback.new(
        email: 'example@example.com',
        comment: 'lorem ipsum',
        rating: '4',
        user_agent: 'Firefox',
        referrer: '/index'
      )
    end

    it 'sets the email' do
      expect(subject.email).to eq('example@example.com')
    end

    it 'sets the comment' do
      expect(subject.comment).to eq('lorem ipsum')
    end

    it 'sets the rating' do
      expect(subject.rating).to eq('4')
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
      Feedback.new(
        email: 'example@example.com',
        comment: 'lorem ipsum',
        rating: '4',
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
        subject.rating = nil
        expect(subject.save).to eq(false)
      end
    end
  end
end
