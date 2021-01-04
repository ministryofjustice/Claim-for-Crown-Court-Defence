# == Schema Information
#
# Table name: injection_attempts
#
#  id             :integer          not null, primary key
#  claim_id       :integer
#  succeeded      :boolean
#  created_at     :datetime
#  updated_at     :datetime
#  error_messages :json
#  deleted_at     :datetime
#

require 'rails_helper'

RSpec.describe InjectionAttempt, type: :model do
  subject(:injection_attempt) { create(:injection_attempt) }

  context 'validations' do
    subject { injection_attempt }

    context 'when claim is present' do
      it { is_expected.to be_valid }
    end

    context 'when claim is missing' do
      before { injection_attempt.claim_id = nil }
      it { is_expected.to be_invalid }
    end
  end

  it { is_expected.to respond_to :soft_delete }
  it { is_expected.to respond_to :active? }
  it { is_expected.to respond_to :softly_deleted? }

  it { is_expected.to respond_to :error_messages }
  it { is_expected.to respond_to :real_error_messages }

  describe '#error_messages' do
    context 'when injection failed' do
      subject { build(:injection_attempt, :with_errors).error_messages }

      it 'returns an Array' do
        is_expected.to be_an Array
      end

      it 'returns a message for each error' do
        is_expected.to include('injection error 1', 'injection error 2')
      end
    end

    context 'when injection succeeded' do
      subject { build(:injection_attempt).error_messages }

      it 'returns empty array for succeeded injections' do
        is_expected.to be_an Array
        is_expected.to be_empty
      end
    end
  end

  describe '#real_error_messages' do
    subject { build(:injection_attempt, :with_errors).real_error_messages }
    let(:errors_json) { '{"errors":[ {"error":"injection error 1"},{"error":"injection error 2"}]}' }
    let(:error_messages) { JSON.parse(errors_json) }

    it 'returns a Hash' do
      is_expected.to be_a Hash
    end

    it 'returns the stored error_messages attribute' do
      is_expected.to eql error_messages
    end

    it 'returned hash has indifferent access' do
      expect(subject['errors']).to eql error_messages['errors']
      expect(subject[:errors]).to eql error_messages['errors']
    end
  end

  describe '#notification_can_be_skipped?' do
    subject(:notification_can_be_skipped?) { injection_attempt.notification_can_be_skipped? }

    context 'when the injection succeeded' do
      let(:injection_attempt) { build(:injection_attempt) }

      it { is_expected.to be true }
    end

    context 'when the injection failed' do
      let(:injection_attempt) { build(:injection_attempt, :with_errors) }

      it { is_expected.to be false }
    end

    context 'when the injection failed with ignorable errors' do
      let(:injection_attempt) { build(:injection_attempt, :with_stat_excluded_errors) }

      it { is_expected.to be true }
    end
  end
end
