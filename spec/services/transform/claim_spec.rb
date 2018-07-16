require 'rails_helper'

RSpec.describe Transform::Claim do
  let(:claim) { create :archived_pending_delete_claim }

  describe 'call' do
    subject(:call) { described_class.call(claim) }

    specify { is_expected.to be_a Hash }

    it 'has the required amount of key/value pairs ' do
      expect(call.count).to eq 52
    end

    context 'runs different import types' do

      it 'retrieves data from linked objects' do
        expect(call[:case_type]).to eq claim.case_type.name
      end

      it 'retrieves data from the claim directly' do
        expect(call[:advocate_category]).to eq claim.advocate_category
      end

      it 'calculates the totals correctly' do
        expect(call[:amount_authorised]).to eq claim.assessment.total + claim.assessment.vat_amount
      end

      it 'counts linked data correctly' do
        expect(call[:num_of_defendants]).to eq claim.defendants.count
      end

      it 'counts linked data with where clauses correctly' do
        expect(call[:refusals]).to eq claim.claim_state_transitions.where("\"to\"='refused'").count
      end

      it 'converts the offence type' do
        expect(call[:offence_type]).to eq claim.offence.offence_class.class_letter
      end

      it 'converts the claim description' do
        expect(call[:claim_type]).to eq 'Advocate final claim'
      end
    end
  end
end
