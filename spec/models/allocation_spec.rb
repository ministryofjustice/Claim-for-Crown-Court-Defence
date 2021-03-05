require 'rails_helper'

RSpec.describe Allocation, type: :model do
  let(:current_user) { create(:case_worker, :admin) }

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
    context 'allocating' do
      let(:case_worker) { create(:case_worker) }
      let(:allocator) { Allocation.new(claim_ids: claims.map(&:id), case_worker_id: case_worker.id, allocating: true, current_user: current_user) }

      context 'when valid' do
        let(:claims) { create_list(:submitted_claim, 3) }

        it 'creates case worker claim join records' do
          allocator.save
          expect(CaseWorkerClaim.where(case_worker_id: case_worker.id).map(&:claim_id)).to match_array(claims.map(&:id))
        end

        it 'sets the claims to allocated' do
          allocator.save
          expect(claims.map(&:reload).map(&:state).uniq).to eq(['allocated'])
        end

        it 'saves audit attributes' do
          allocator.save
          transition = claims.first.last_state_transition
          expect(transition.author_id).to eq(current_user.id)
          expect(transition.subject_id).to eq(case_worker.user.id)
        end

        it 'returns true' do
          expect(allocator.save).to eq(true)
        end
      end

      context 'when valid, but allocation bug occurs' do
        subject { allocator.save }
        let(:claims) { create_list(:submitted_claim, 1) }
        let(:case_worker_dbl) { double(Array, empty?: true, exists?: false) }
        before do
          allow(case_worker_dbl).to receive(:<<)
          allow(case_worker_dbl).to receive(:pluck).and_return(['1'])
          allow_any_instance_of(Claim::BaseClaim).to receive(:case_workers).and_return(case_worker_dbl)
        end

        it 'logs the error' do
          expect(LogStuff).to receive(:error).once
          subject
        end

        it { is_expected.to be false }
      end

      context 'when in an invalid state' do
        let(:claims) { create_list(:allocated_claim, 2) }

        it 'returns false' do
          expect(allocator.save).to be false
        end

        it 'details the errors' do
          allocator.save
          expect(allocator.errors[:base].size).to eq 3
          expect(allocator.errors[:base][0]).to match(/^Claim [A-Z][0-9]{8} has already been allocated to/)
          expect(allocator.errors[:base][1]).to match(/^Claim [A-Z][0-9]{8} has already been allocated to/)
          expect(allocator.errors[:base][2]).to eq('NO claims were allocated')
        end
      end

      context 'when creator is a litigator' do
        let!(:claim) { create :submitted_claim }
        let(:allocator) { Allocation.new(claim_ids: [claim.id], case_worker_id: case_worker.id, allocating: true, current_user: current_user) }

        describe 'and then changes role to advocate' do
          before do
            claim.creator.roles = ['litigator']
            claim.creator.save!
          end

          it 'allows the allocation of the claim' do
            expect(allocator.save).to be true
          end
        end
      end

      context 'when invalid because no caseworker id specified' do
        let(:claims) { create_list(:submitted_claim, 3) }
        let(:allocator) { Allocation.new(claim_ids: claims.map(&:id), allocating: true) }

        it 'returns false' do
          expect(allocator.save).to be false
        end

        it 'leaves the claims in submitted state' do
          allocator.save
          claims.each do |claim|
            expect(claim.reload.state).to eq 'submitted'
          end
        end

        it 'details the errors' do
          allocator.save
          expect(allocator.errors[:case_worker_id]).to include("can't be blank")
        end
      end
    end

    context 'reallocating' do
      let(:case_worker) { create(:case_worker) }
      let(:reallocator) { Allocation.new(claim_ids: claims.map(&:id), case_worker_id: case_worker.id, current_user: current_user) }

      context 'when valid' do
        let(:claims) { create_list(:allocated_claim, 3) }

        it 'reponds true to reallocating?()' do
          expect(reallocator.__send__(:reallocating?)).to be true
        end

        it 'creates case worker claim join records' do
          reallocator.save
          expect(CaseWorkerClaim.where(case_worker_id: case_worker.id).map(&:claim_id)).to match_array(claims.map(&:id))
        end

        it 'sets the claims to allocated' do
          reallocator.save
          expect(claims.map(&:reload).map(&:state).uniq).to eq(['allocated'])
        end

        it 'saves audit attributes' do
          reallocator.save
          transition = claims.first.last_state_transition
          expect(transition.author_id).to eq(current_user.id)
          expect(transition.subject_id).to eq(case_worker.user.id)
        end

        it 'returns true' do
          expect(reallocator.save).to eq(true)
        end
      end

      context 'when in an invalid state' do
        let(:claims) { create_list(:submitted_claim, 2) }
        let(:reallocator) { Allocation.new(claim_ids: claims.map(&:id), case_worker_id: case_worker.id) }

        it 'responds true to reallocating?' do
          expect(reallocator.__send__(:reallocating?)).to be true
        end

        it 'returns false' do
          expect(reallocator.save).to be false
        end

        it 'details the errors' do
          reallocator.save
          expect(reallocator.errors[:base].size).to eq 2
          expect(reallocator.errors[:base]).to include("Claim #{claims.first.id} cannot be transitioned to reallocation from submitted")
          expect(reallocator.errors[:base]).to include("Claim #{claims.last.id} cannot be transitioned to reallocation from submitted")
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
          expect(subject.errors.full_messages.first).to match(/Claim .* has already been allocated/)
          expect(subject.errors.full_messages.second).to match(/NO claims were allocated/)
          expect(case_worker.claims.count).to eq 0
        end
      end

      context 'when re-allocating' do
        before { allow(subject).to receive(:allocating?).and_return(nil) }

        it 'claims will be re-allocated' do
          submitted_claim_id = claims.detect { |c| c.submitted? }.id
          subject.save
          expect(case_worker.claims.count).to eq 0
          expect(subject.errors[:base]).to include("Claim #{submitted_claim_id} cannot be transitioned to reallocation from submitted")
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

        subject { Allocation.new(claim_ids: claims.map(&:id), deallocate: true, current_user: current_user) }

        it 'deletes case worker claim join records' do
          subject.save
          expect(case_worker.reload.claims).to be_empty
        end

        it 'returns true' do
          expect(subject.save).to eq(true)
        end

        it 'saves audit attributes' do
          subject.save
          transition = claims.first.last_state_transition
          expect(transition.author_id).to eq(current_user.id)
          expect(transition.subject_id).to be_nil
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
