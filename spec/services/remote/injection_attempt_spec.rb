require 'rails_helper'

module Remote
  describe InjectionAttempt do
    let(:injection_attempt) { ::Remote::InjectionAttempt.new(succeeded: false, error_messages: ['injection error 1', 'injection error 2']) }

    describe '#succeeded' do
      subject { injection_attempt.succeeded }
      it 'returns false for successful attempts' do
        is_expected.to be_falsey
      end
    end

    describe '#active?' do
      subject { injection_attempt.active? }
      it 'returns true when not softly deleted' do
        allow(injection_attempt).to receive(:deleted_at).and_return nil
        is_expected.to be_truthy
      end

      it 'returns false when softly deleted' do
        allow(injection_attempt).to receive(:deleted_at).and_return DateTime.now
        is_expected.to be_falsey
      end
    end

    describe '#error_messages' do
      subject { injection_attempt.error_messages }
      it 'returns array of injection error messages' do
        is_expected.to match_array(['injection error 1', 'injection error 2'])
      end
    end
  end
end
