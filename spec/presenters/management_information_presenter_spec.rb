require 'rails_helper'

module ClaimAllocatorHelpers
  def claim_allocator_call!(options)
    allocator = Allocation.new(options)
    allocator.save
    claim.reload
  end

  def debug_transitions_for(claim)
    claim.claim_state_transitions.sort.map do |t|
      { from: t.from,
        to: t.to,
        by: ("#{User.find(t.author_id).name} (#{User.find(t.author_id).persona.class})" if t.author_id),
        assignee: (User.find(t.subject_id).name if t.subject_id),
        reason: t.reason_text,
        transitioned_at: t.created_at.strftime('%d/%m/%Y') }
    end
  end
end

RSpec.configure do |c|
  c.include ClaimAllocatorHelpers, :include_allocator_helpers
end

RSpec.describe ManagementInformationPresenter do
  let(:claim) { create(:redetermination_claim) }
  let(:presenter) { ManagementInformationPresenter.new(claim, view) }
  let(:previous_user) { create(:user, first_name: 'Thea', last_name: 'Conway') }
  let(:another_user) { create(:user, first_name: 'Hilda', last_name: 'Rogers') }

  context '#present!' do
    context 'with identical values for' do
      it 'case_number' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include(claim.case_number)
          expect(claim_journeys.second).to include(claim.case_number)
        end
      end

      it 'supplier number' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include(claim.supplier_number)
          expect(claim_journeys.second).to include(claim.supplier_number)
        end
      end

      it 'organisation/provider_name' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include(claim.external_user.provider.name)
          expect(claim_journeys.second).to include(claim.external_user.provider.name)
        end
      end

      it 'case_type' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include(claim.case_type.name)
          expect(claim_journeys.second).to include(claim.case_type.name)
        end
      end

      context 'AGFS' do
        it 'scheme' do
          presenter.update_column(:type, 'Claim::AdvocateInterimClaim')

          presenter.present! do |claim_journeys|
            expect(claim_journeys.first).to include('AGFS')
            expect(claim_journeys.second).to include('AGFS')
          end
        end

        it 'bill_type' do
          presenter.update_column(:type, 'Claim::AdvocateInterimClaim')

          presenter.present! do |claim_journeys|
            expect(claim_journeys.first).to include('AGFS Interim')
            expect(claim_journeys.second).to include('AGFS Interim')
          end
        end
      end

      context 'LGFS' do
        let(:claim) { create(:litigator_claim, :redetermination) }

        it 'scheme' do
          presenter.update_column(:type, 'Claim::LitigatorClaim')

          presenter.present! do |claim_journeys|
            expect(claim_journeys.first).to include('LGFS')
            expect(claim_journeys.second).to include('LGFS')
          end
        end

        it 'bill_type' do
          presenter.update_column(:type, 'Claim::LitigatorHardshipClaim')

          presenter.present! do |claim_journeys|
            expect(claim_journeys.first).to include('LGFS Hardship')
            expect(claim_journeys.second).to include('LGFS Hardship')
          end
        end
      end

      it 'total (inc VAT)' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include(claim.total_including_vat.to_s)
          expect(claim_journeys.second).to include(claim.total_including_vat.to_s)
        end
      end

      it 'disc evidence' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include('No')
          expect(claim_journeys.second).to include('No')
        end
      end
    end

    describe '#disc evidence' do
      subject { presenter.disk_evidence_case }

      context 'when the applicant has checked disc_evidence' do
        let(:claim) { create :advocate_claim, disk_evidence: true }

        it { is_expected.to eq 'Yes' }
      end

      context 'when the applicant has not checked disc_evidence' do
        let(:claim) { create :advocate_claim }

        it { is_expected.to eq 'No' }
      end
    end

    describe '#main_defendant' do
      subject { presenter.main_defendant }

      it { is_expected.to eq claim.defendants.first.name }
    end

    describe '#maat_reference' do
      subject { presenter.maat_reference }

      it { is_expected.to eq claim.earliest_representation_order.maat_reference }
    end

    describe '#rep_order_issued_date' do
      subject { presenter.rep_order_issued_date }

      it { is_expected.to eq claim.earliest_representation_order&.representation_order_date&.strftime('%d/%m/%Y') }
    end

    describe '#case_worker', :include_allocator_helpers do
      subject(:case_worker) { presenter.case_worker }

      let(:claim) do
        create(:advocate_claim, external_user: external_user1).tap do |claim|
          claim.submit!(author_id: claim.external_user.user.id)
        end
      end

      let(:external_user1) { create(:external_user, build_user: false, user: create(:user, first_name: 'External', last_name: 'User1')) }

      let(:case_worker_admin) { create(:case_worker, :admin, build_user: false, user: create(:user, first_name: 'Casey', last_name: 'WorkerAdmin')) }
      let(:case_worker1) { create(:case_worker, build_user: false, user: create(:user, first_name: 'Casey', last_name: 'Worker1')) }
      let(:case_worker2) { create(:case_worker, build_user: false, user: create(:user, first_name: 'Casey', last_name: 'Worker2')) }
      let(:case_worker3) { create(:case_worker, build_user: false, user: create(:user, first_name: 'Casey', last_name: 'Worker3')) }
      let(:case_worker_name_idx) { 17 }

      let(:allocator_options) do
        { current_user: case_worker_admin.user,
          claim_ids: [claim.id],
          deallocate: false,
          allocating: true }
      end

      context 'with a submitted claim' do
        it {
          presenter.present! do |claim_journeys|
            is_expected.to eql 'n/a'
          end
        }
      end

      context 'with a submitted, allocated claim' do
        before do
          travel_to(7.days.ago) do
            claim_allocator_call!(allocator_options.merge(case_worker_id: case_worker1.id))
          end
        end

        it 'returns the name of the caseworker allocated to the claim' do
          presenter.present! do |claim_journeys|
            is_expected.to eq case_worker1.user.name
          end
        end
      end

      context 'with a submitted, rejected, then awaiting redetermination claim' do
        before do
          travel_to(7.days.ago) do
            claim_allocator_call!(allocator_options.merge(case_worker_id: case_worker1.id))
          end

          travel_to(6.days.ago) { claim.reject!(author_id: case_worker1.user.id, reason_code: ['other'], reason_text: 'I am rejecting') }
          travel_to(5.days.ago) { claim.redetermine!(author_id: claim.external_user.user.id) }
        end

        it {
          presenter.present! do |claim_journeys|
            is_expected.to eql 'n/a'
          end
        }
      end

      context 'with a submitted, rejected then awaiting written reasons claim' do
        before do
          travel_to(7.days.ago) do
            claim_allocator_call!(allocator_options.merge(case_worker_id: case_worker1.id))
          end

          travel_to(6.days.ago) { claim.reject!(author_id: case_worker1.user.id, reason_code: ['other'], reason_text: 'I am rejecting') }
          travel_to(5.days.ago) { claim.await_written_reasons!(author_id: claim.external_user.user.id) }
        end

        it {
          presenter.present! do |claim_journeys|
            is_expected.to eql 'n/a'
          end
        }
      end

      context 'with a submitted, allocated then authorised claim' do
        before do
          travel_to(7.days.ago) do
            claim_allocator_call!(allocator_options.merge(case_worker_id: case_worker1.id))
          end

          travel_to(6.days.ago) do
            assign_fees_and_expenses_for(claim)
            claim.authorise!(author_id: case_worker1.user.id)
          end
        end

        it 'returns name of the caseworker that made the decision' do
          presenter.present! do |claim_journeys|
            case_worker_names = claim_journeys.map { |journey| journey[case_worker_name_idx] }
            is_expected.to eq(case_worker_names.last)
          end
        end
      end

      context 'with a rejected, redetermined, part_authorised, redetermined and then fully authorised claim' do
        before do
          travel_to(7.days.ago) do
            claim_allocator_call!(allocator_options.merge(case_worker_id: case_worker1.id))
          end

          travel_to(6.days.ago) { claim.reject!(author_id: case_worker1.user.id, reason_code: ['other'], reason_text: 'I am rejecting') }
          travel_to(5.days.ago) { claim.redetermine! }

          travel_to(4.days.ago) do
            claim_allocator_call!(allocator_options.merge(case_worker_id: case_worker2.id))
          end

          travel_to(3.days.ago) do
            assign_fees_and_expenses_for(claim)
            claim.authorise_part!(author_id: case_worker2.user.id)
          end

          travel_to(2.days.ago) { claim.redetermine! }

          travel_to(1.day.ago) do
            claim_allocator_call!(allocator_options.merge(case_worker_id: case_worker3.id))
          end

          assign_fees_and_expenses_for(claim)
          claim.authorise!(author_id: case_worker3.user.id)
        end

        it 'returns name of the caseworker that made each decision' do
          presenter.present! do |claim_journeys|
            case_worker_names = claim_journeys.map { |journey| journey[case_worker_name_idx] }
            expect(case_worker_names).to match_array([case_worker1.name, case_worker2.name, case_worker3.name])
          end
        end
      end
    end

    describe '#af1_lf1_processed_by' do
      context 'an allocated claim' do
        it 'returns nil' do
          claim = create :authorised_claim
          presenter = ManagementInformationPresenter.new(claim, view)
          presenter.present! do |claim_journeys|
            expect(presenter.af1_lf1_processed_by).to eq ''
          end
        end
      end

      context 'a redetermined claim' do
        it 'returns the name of the last caseworker to update before redetermination' do
          claim = create :authorised_claim
          transition = claim.last_decision_transition
          transition.update_author_id(previous_user.id)
          claim.redetermine!
          presenter = ManagementInformationPresenter.new(claim, view)
          presenter.present! do |claim_journeys|
            expect(presenter.af1_lf1_processed_by).to eq previous_user.name
          end
        end
      end

      context 'a claim that is redetermined twice' do
        it 'returns the name of the last caseworker to update before redetermination' do
          claim = create :redetermination_claim
          claim.allocate!
          claim.authorise!
          transition = claim.last_decision_transition
          transition.update_author_id(another_user.id)
          claim.redetermine!
          presenter = ManagementInformationPresenter.new(claim, view)
          presenter.present! do |claim_journeys|
            expect(presenter.af1_lf1_processed_by).to eq another_user.name
          end
        end
      end
    end

    describe '#misc_fees' do
      subject { presenter.misc_fees }

      it { is_expected.to eq claim.misc_fees.map { |f| f.fee_type.description.tr(',', '') }.join(' ') }
    end

    describe '#transitioned_at' do
      it 'set per transition' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include((Time.zone.now - 3.day).strftime('%d/%m/%Y'))
          expect(claim_journeys.second).to include((Time.zone.now).strftime('%d/%m/%Y'))
        end
      end
    end

    describe '#last_submitted_at' do
      subject { presenter.last_submitted_at }

      let(:last_submitted_at) { Date.new(2017, 9, 20) }

      before do
        claim.last_submitted_at = last_submitted_at
      end

      it { is_expected.to eql last_submitted_at.strftime('%d/%m/%Y') }
    end

    describe '#originally_submitted_at' do
      subject { presenter.originally_submitted_at }

      let(:original_submission_date) { Date.new(2015, 6, 18) }

      before do
        claim.original_submission_date = original_submission_date
      end

      it { is_expected.to eql original_submission_date.strftime('%d/%m/%Y') }
    end

    context 'and unique values for' do
      before { Timecop.freeze(Time.now) }
      after { Timecop.return }

      it 'submission type' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include('new')
          expect(claim_journeys.second).to include('redetermination')
        end
      end

      it 'date allocated' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include((Time.zone.now - 2.day).strftime('%d/%m/%Y'))
          expect(claim_journeys.second).to include('n/a', 'n/a')
        end
      end

      it 'date of last assessment' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include((Time.zone.now - 1.day).strftime('%d/%m/%Y %H:%M'))
          expect(claim_journeys.second).to include('n/a', 'n/a')
        end
      end

      it 'current/end state' do
        presenter.present! do |claim_journeys|
          expect(claim_journeys.first).to include('authorised')
          expect(claim_journeys.second).to include('submitted')
        end
      end
    end

    context 'deallocation' do
      let(:claim) { create(:allocated_claim) }

      before {
        case_worker = claim.case_workers.first
        claim.deallocate!
        claim.case_workers << case_worker
        claim.reload.deallocate!
      }

      it 'should not be reflected in the MI' do
        ManagementInformationPresenter.new(claim, view).present! do |csv|
          expect(csv[0]).not_to include('deallocated')
        end
      end

      it 'and the claim should be refelcted as being in the state prior to allocation' do
        ManagementInformationPresenter.new(claim, view).present! do |csv|
          expect(csv[0]).to include('submitted')
        end
      end
    end

    context 'archived_pending_delete' do
      let(:claim) { create(:archived_pending_delete_claim) }

      it 'adds a single row to the MI' do
        ManagementInformationPresenter.new(claim, view).present! do |csv|
          expect(csv.size).to eql 1
        end
      end

      it 'should not be reflected in the MI' do
        ManagementInformationPresenter.new(claim, view).present! do |csv|
          expect(csv[0]).not_to include('archived_pending_delete')
        end
      end

      it 'and the claim should be reflected as being in the state prior to archive' do
        ManagementInformationPresenter.new(claim, view).present! do |csv|
          expect(csv[0]).to include('authorised')
        end
      end
    end

    context 'archived_pending_review' do
      let(:claim) { create(:hardship_archived_pending_review_claim) }

      it 'adds a single row to the MI' do
        ManagementInformationPresenter.new(claim, view).present! do |csv|
          expect(csv.size).to eql 1
        end
      end

      it 'should not be reflected in the MI' do
        ManagementInformationPresenter.new(claim, view).present! do |csv|
          expect(csv[0]).not_to include('archived_pending_review')
        end
      end

      it 'and the claim should be reflected as being in the state prior to archive' do
        ManagementInformationPresenter.new(claim, view).present! do |csv|
          expect(csv[0]).to include('authorised')
        end
      end
    end

    context 'state transitions reasons' do
      let(:claim) { create(:allocated_claim) }
      let(:colidx) { 15 }

      context 'rejected with a single reason as a string ' do
        before do
          claim.reject!(reason_code: ['no_rep_order'])
        end

        it 'the rejection reason code should be reflected in the MI' do
          allow_any_instance_of(ClaimStateTransition).to receive(:reason_code).and_return('no_rep_order')
          ManagementInformationPresenter.new(claim, view).present! do |csv|
            expect(csv[0][colidx]).to eq('no_rep_order')
          end
        end
      end

      context 'rejected with a single reason' do
        before do
          claim.reject!(reason_code: ['no_rep_order'])
        end

        it 'the rejection reason code should be reflected in the MI' do
          ManagementInformationPresenter.new(claim, view).present! do |csv|
            expect(csv[0][colidx]).to eq('no_rep_order')
          end
        end
      end

      context 'rejected with a multiple reasons' do
        before do
          claim.reject!(reason_code: ['no_rep_order', 'wrong_case_no'])
        end

        it 'the rejection reason code should be reflected in the MI' do
          ManagementInformationPresenter.new(claim, view).present! do |csv|
            expect(csv[0][colidx]).to eq('no_rep_order, wrong_case_no')
          end
        end
      end

      context 'rejected with other' do
        before do
          claim.reject!(reason_code: ['other'], reason_text: 'Rejection reason')
        end

        it 'the rejection reason code should be reflected in the MI' do
          ManagementInformationPresenter.new(claim, view).present! do |csv|
            expect(csv[0][colidx]).to eq('other')
            expect(csv[0][colidx + 1]).to eq('Rejection reason')
          end
        end
      end

      context 'refused with a single reason as a string ' do
        before do
          claim.refuse!(reason_code: ['no_rep_order'])
        end

        it 'the refusal reason code should be reflected in the MI' do
          allow_any_instance_of(ClaimStateTransition).to receive(:reason_code).and_return('no_rep_order')
          ManagementInformationPresenter.new(claim, view).present! do |csv|
            expect(csv[0][colidx]).to eq('no_rep_order')
          end
        end
      end

      context 'refused with a single reason' do
        before do
          claim.refuse!(reason_code: ['no_rep_order'])
        end

        it 'the refusal reason code should be reflected in the MI' do
          ManagementInformationPresenter.new(claim, view).present! do |csv|
            expect(csv[0][colidx]).to eq('no_rep_order')
          end
        end
      end

      context 'refused with multiple reasons' do
        before do
          claim.refuse!(reason_code: ['no_rep_order', 'wrong_case_no'])
        end

        it 'the refusal reason code should be reflected in the MI' do
          ManagementInformationPresenter.new(claim, view).present! do |csv|
            expect(csv[0][colidx]).to eq('no_rep_order, wrong_case_no')
          end
        end
      end

      context 'rejected with other' do
        before do
          claim.reject!(reason_code: ['other'], reason_text: 'Rejection reason')
        end

        it 'the rejection reason code should be reflected in the MI' do
          ManagementInformationPresenter.new(claim, view).present! do |csv|
            expect(csv[0][colidx]).to eq('other')
            expect(csv[0][colidx + 1]).to eq('Rejection reason')
          end
        end
      end
    end
  end
end
