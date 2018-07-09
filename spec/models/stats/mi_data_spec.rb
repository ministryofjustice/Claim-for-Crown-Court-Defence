require 'rails_helper'

module Stats
  describe MIData do
    subject { described_class.new }

    it { is_expected.to be_a Stats::MIData }

    it { expect(subject.attributes.size).to eq 53 }

    it { expect(subject).to_not respond_to :import }

    describe '.import' do
      subject(:import) { described_class.import(claim) }

      let(:claim) { create :archived_pending_delete_claim }
      it { is_expected.to be true }
      it { expect { import }.to change { Stats::MIData.count }.by 1 }

      context 'runs different import types' do
        before { import }

        let(:new_mi) { Stats::MIData.last }

        it 'retrieves data from linked objects' do
          expect(new_mi.case_type).to eq claim.case_type.name
        end

        it 'retrieves data from the claim directly' do
          expect(new_mi.advocate_category).to eq claim.advocate_category
        end

        it 'calculates the totals correctly' do
          expect(new_mi.amount_authorised).to eq claim.assessment.total + claim.assessment.vat_amount
        end

        it 'counts linked data correctly' do
          expect(new_mi.num_of_defendants).to eq claim.defendants.count
        end

        it 'counts linked data with where clauses correctly' do
          expect(new_mi.refusals).to eq claim.claim_state_transitions.where("\"to\"='refused'").count
        end

        it 'converts the offence type' do
          expect(new_mi.offence_type).to eq claim.offence.offence_class.class_letter
        end

        it 'converts the claim description' do
          expect(new_mi.claim_type).to eq 'Advocate final claim'
        end
      end
    end
  end
end
