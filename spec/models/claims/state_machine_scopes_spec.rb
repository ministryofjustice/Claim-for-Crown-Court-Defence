require 'rails_helper'

RSpec.describe Claims::StateMachine, type: :model do
  subject { create(:claim) }

  describe 'all available states are scoped' do
    let(:states) { subject.class.state_machine.states.map(&:name) }

    it 'and accessible' do
      states.each do |state|
        subject.update_column(:state, state.to_s)
        expect(subject.class.send(state)).to match_array(subject)
      end
    end
  end
end
