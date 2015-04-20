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

      context 'when completed' do
        before do
          subject.submit!
          subject.complete!
        end

        it 'should raise error' do
          expect{subject.submit!}.to raise_error
        end
      end
    end

    describe '#complete' do
      subject { create(:submitted_claim) }

      context 'when submitted' do
        before { subject.complete! }

        it 'should transition to "completed"' do
          expect(subject).to be_completed
        end
      end

      context 'when draft' do
        subject { create(:claim) }

        it 'should raise error' do
          expect{subject.complete!}.to raise_error
        end
      end

      context 'when completed' do
        before { subject.complete! }

        it 'should raise error' do
          expect{subject.complete!}.to raise_error
        end
      end
    end

    describe '#set_submission_date!' do
      it 'sets the submission date/time to now' do
        Timecop.freeze(Time.now) do
          subject.send(:set_submission_date!)
          expect(subject.submitted_at.to_time).to eq(Time.now)
        end
      end
    end
  end

  context 'scopes' do
    let!(:claim_1) { create(:claim) }
    let!(:claim_2) { claim = create(:claim); claim.submit!; claim }
    let!(:claim_3) { create(:claim) }
    let!(:claim_4) { create(:completed_claim) }

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

    describe '.completed' do
      it 'only returns completed claims' do
        expect(Claim.completed).to match_array([claim_4])
      end
    end
  end
end
