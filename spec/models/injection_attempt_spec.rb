# == Schema Information
#
# Table name: injection_attempts
#
#  id            :integer          not null, primary key
#  claim_id      :integer
#  succeeded     :boolean
#  error_message :string
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

RSpec.describe InjectionAttempt, type: :model do
  subject(:injection_attempt) { build(:injection_attempt, attributes) }

  let(:attributes) { { succeeded: true, error_message: nil } }

  context 'scopes' do
    describe '.errored' do
      subject { claim.injection_attempts.errored }
      let(:claim) { create(:submitted_claim, :with_injection_error) }

      it 'returns injection attempts that failed' do
        expect(claim.injection_attempts.errored.count).to eql 1
      end
    end
  end

  context 'validations' do
    subject { injection_attempt }

    context 'when claim is present' do
      it { is_expected.to be_valid }
    end

    context 'when claim is missing' do
      let(:attributes) { { claim: nil } }

      it { is_expected.to be_invalid }
    end
  end
end

