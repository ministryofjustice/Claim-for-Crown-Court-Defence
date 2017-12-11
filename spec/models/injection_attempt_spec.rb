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
  subject(:injection_attempt) { build(:injection_attempt, params) }

  let(:params) { { succeeded: true, error_message: nil } }

  describe 'validations' do
    subject { injection_attempt.valid? }

    it { is_expected.to be true }

    context 'when claim is missing' do
      let(:params) { { claim: nil } }

      it { is_expected.to be false }
    end
  end
end

