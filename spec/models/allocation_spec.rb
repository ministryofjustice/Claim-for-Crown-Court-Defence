require 'rails_helper'

RSpec.describe Allocation, type: :model do
  it { should validate_presence_of(:case_worker_id) }
  it { should validate_presence_of(:claim_ids) }

  describe '#initialize' do
    subject { Allocation.new(case_worker_id: 1, claim_ids: [1, 2, 3]) }

    it 'sets the case worker id' do
      expect(subject.case_worker_id).to eq(1)
    end

    it 'sets the claim ids' do
      expect(subject.claim_ids).to match_array([1, 2, 3])
    end
  end

  describe '#save' do

    context 'allocating and re-allocating' do
      let(:claims) { create_list(:submitted_claim, 3) }
      let(:case_worker) { create(:case_worker) }

      context 'when valid' do
        subject { Allocation.new(claim_ids: claims.map(&:id), case_worker_id: case_worker.id) }

        it 'creates case worker claim join records' do
          subject.save
          expect(CaseWorkerClaim.where(case_worker_id: case_worker.id).map(&:claim_id)).to match_array(claims.map(&:id))
        end

        it 'sets the claims to "allocated"' do
          subject.save
          expect(claims.map(&:reload).map(&:state).uniq).to eq(['allocated'])
        end

        it 'returns true' do
          expect(subject.save).to eq(true)
        end
      end

      context 'when invalid' do
        subject { Allocation.new(claim_ids: claims.map(&:id)) }

        it 'does not create case worker claim join records' do
          subject.save
          expect(CaseWorkerClaim.count).to eq(0)
        end

        it 'returns false' do
          expect(subject.save).to eq(false)
        end

        it 'contains errors' do
          subject.save
          expect(subject.errors).to_not be_empty
        end
      end
    end

    context 'when already allocated claims included' do
      let(:case_worker) { create(:case_worker) }
      let(:claims) do
        claims = create_list(:submitted_claim, 1)
        claims << create(:allocated_claim)
      end

      subject { Allocation.new(claim_ids: claims.map(&:id), case_worker_id: case_worker.id) }

      context 'when allocating' do
        before { allow(subject).to receive(:allocating?).and_return(true) }

        it 'NO claims will be allocated' do
          subject.save
          expect(claims.count).to eq 2
          expect(case_worker.claims.count).to eq 0
        end

        it 'will populate allocation errors including header without failing' do
          subject.save
          expect(subject.errors.count).to eq 2 # claim error plus heading error warning
          expect(subject.errors.full_messages.first).to match(/NO claims allocated/)
          expect(subject.errors.full_messages.second).to match(/Claim .* has already been allocated/)
          expect(case_worker.claims.count).to eq 0
        end
      end

      context 'when re-allocating' do
        before { allow(subject).to receive(:allocating?).and_return(nil) }

        it 'claims will be re-allocated' do
          subject.save
          expect(case_worker.claims.count).to eq 2
        end
      end
    end

    context 'deallocating' do
      let(:claims) { create_list(:submitted_claim, 2) }
      let(:case_worker) { create(:case_worker) }

      context 'when valid' do
        before do
          claims.each do |claim|
            claim.case_workers << case_worker
          end
        end

        subject { Allocation.new(claim_ids: claims.map(&:id), deallocate: true) }

        it 'deletes case worker claim join records' do
          subject.save
          expect(case_worker.reload.claims).to be_empty
        end

        it 'returns true' do
          expect(subject.save).to eq(true)
        end

        describe 'state change' do
          before { subject.save }

          context 'for submitted claims' do
            let(:claims) { create_list(:submitted_claim, 2) }

            it 'sets the claims to the state to "submitted"' do
              expect(claims.map(&:reload).map(&:state).uniq).to eq(['submitted'])
            end
          end

          context 'for redetermination claims' do
            let(:claims) { create_list(:redetermination_claim, 2) }

            it 'sets the claims state to "redetermination"' do
              expect(claims.map(&:reload).map(&:state).uniq).to eq(['redetermination'])
            end
          end
        end
      end

      context 'when invalid' do
        subject { Allocation.new(claim_ids: claims.map(&:id)) }

        before do
          claims.each do |claim|
            claim.case_workers << case_worker
          end
        end

        it 'does not create case worker claim join records' do
          subject.save
          expect(CaseWorkerClaim.count).to eq(2)
        end

        it 'does not delete case worker claim join records' do
          subject.save
          expect(CaseWorkerClaim.count).to eq(2)
        end

        it 'leaves the claims as "allocated"' do
          subject.save
          expect(claims.map(&:reload).map(&:state).uniq).to eq(['allocated'])
        end

        it 'returns false' do
          expect(subject.save).to eq(false)
        end

        it 'contains errors' do
          subject.save
          expect(subject.errors).to_not be_empty
        end
      end
    end
  end
end
