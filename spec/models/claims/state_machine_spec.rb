require 'rails_helper'

RSpec.describe Claims::StateMachine, type: :model do
  subject { create(:claim) }

  it 'should have an initial state of "draft"' do
    expect(subject.state).to eq('draft')
  end

  describe '#submit' do
    it 'should transition to "submitted"' do
      subject.submit!
      expect(subject).to be_submitted
    end
  end
end
