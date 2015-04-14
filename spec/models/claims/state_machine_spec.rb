require 'rails_helper'

RSpec.describe Claims::StateMachine, type: :model do
  context 'states' do
    subject { create(:claim) }

    it 'should have an initial state of "draft"' do
      expect(subject.state).to eq('draft')
    end

    describe '#submit' do
      context 'when draft' do
        before { subject.submit! }

        it 'should transition to "submitted"' do
          expect(subject).to be_submitted
        end

        it 'should set submitted_at' do
          expect(subject.submitted_at).to_not be_nil
        end
      end

      context 'when submitted' do
        before { subject.submit! }

        it 'should not raise error' do
          expect{subject.submit!}.to_not raise_error
        end
      end
    end

    describe '#set_submission_date!' do
      it 'sets the submission date/time to now' do
        Timecop.freeze(Time.now) do
          subject.send(:set_submission_date!)
          expect(subject.submitted_at.strftime('%d/%m/%Y %H:%M:%S')).to eq(Time.now.strftime('%d/%m/%Y %H:%M:%S'))
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
