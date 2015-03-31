require 'rails_helper'

RSpec.describe Claims::StateMachine, type: :model do
  context 'states' do
    subject { create(:claim) }

    it 'should have an initial state of "draft"' do
      expect(subject.state).to eq('draft')
    end

    describe '#submit' do
      context 'when draft' do
        it 'should transition to "submitted"' do
          subject.submit!
          expect(subject).to be_submitted
        end
      end

      context 'when submitted' do
        before { subject.submit! }

        it 'should not raise error' do
          expect{subject.submit!}.to_not raise_error
        end
      end
    end
  end

  context 'scopes' do
    let!(:claim_1) { create(:claim) }
    let!(:claim_2) { claim = create(:claim); claim.submit!; claim }
    let!(:claim_3) { create(:claim) }

    describe '.draft' do
      it 'only returns draft claims' do
        expect(Claim.draft).to match_array([claim_1, claim_3])
      end
    end

    describe '.submitted' do
      it 'only returns submitted claims' do
        expect(Claim.submitted).to match_array([claim_2])
      end
    end
  end
end
