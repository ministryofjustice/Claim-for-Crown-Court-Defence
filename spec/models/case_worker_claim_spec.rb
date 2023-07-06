# == Schema Information
#
# Table name: case_worker_claims
#
#  id             :integer          not null, primary key
#  case_worker_id :integer
#  claim_id       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe CaseWorkerClaim do
  subject(:case_worker_claim) { create(:case_worker_claim, case_worker:, claim:) }

  let(:claim) { create(:claim, :submitted) }
  let(:case_worker) { create(:case_worker) }

  it { is_expected.to belong_to(:claim) }
  it { is_expected.to belong_to(:case_worker) }

  describe '#generate_message_statuses' do
    before do
      messages = create_list(:message, 3)
      claim.messages << messages
    end

    it { expect { case_worker_claim }.to change(UserMessageStatus, :count).by(3) }
  end

  describe '#set_claim_allocated!' do
    context 'when the claim is submitted' do
      it { expect(case_worker_claim.claim).to be_allocated }
    end

    context 'when the claim is being redetermined' do
      let(:claim) { create(:claim, :redetermination) }

      it { expect(case_worker_claim.claim).to be_allocated }
    end

    context 'when the claim is awaiting written reasons' do
      let(:claim) { create(:claim, :awaiting_written_reasons) }

      it { expect(case_worker_claim.claim).to be_allocated }
    end

    context 'when the claim is in draft' do
      let(:claim) { create(:claim, :draft) }

      it { expect(case_worker_claim.claim).not_to be_allocated }
    end
  end
end
