require 'rails_helper'

RSpec.describe ClaimCsvPresenter do

  let(:claim)               { create(:redetermination_claim) }
  let(:subject)             { ClaimCsvPresenter.new(claim, view) }

  context '#present!' do

    context 'generates a line of CSV for each time a claim passes through the system' do

      context 'with identical values for' do

        it 'case_number' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.case_number)
            expect(claim_journeys.second).to include(claim.case_number)
          end
        end

        it 'supplier number' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.supplier_number)
            expect(claim_journeys.second).to include(claim.supplier_number)
          end
        end

        it 'organisation/provider_name' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.external_user.provider.name)
            expect(claim_journeys.second).to include(claim.external_user.provider.name)
          end
        end

        it 'case_type' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.case_type.name)
            expect(claim_journeys.second).to include(claim.case_type.name)
          end
        end

        context 'AGFS' do
          it 'scheme' do
            subject.present! do |claim_journeys|
              expect(claim_journeys.first).to include('AGFS')
              expect(claim_journeys.second).to include('AGFS')
            end
          end
        end

        context 'LGFS' do
          it 'scheme' do
            subject.update_column(:type, 'Claim::LitigatorClaim')

            subject.present! do |claim_journeys|
              expect(claim_journeys.first).to include('LGFS')
              expect(claim_journeys.second).to include('LGFS')
            end
          end
        end

        it 'total (inc VAT)' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include(claim.total_including_vat.to_s)
            expect(claim_journeys.second).to include(claim.total_including_vat.to_s)
          end
        end

        it 'disc evidence' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include('No')
            expect(claim_journeys.second).to include('No')
          end
        end
      end

      describe 'disc evidence' do
        subject { ClaimCsvPresenter.new(claim, view).disk_evidence_case }

        context 'when the applicant has checked disc_evidence' do
          let(:claim) { create :advocate_claim, disk_evidence: true }

          it { is_expected.to eq 'Yes' }
        end

        context 'when the applicant has not checked disc_evidence' do
          let(:claim) { create :advocate_claim }

          it { is_expected.to eq 'No' }
        end
      end

      describe 'caseworker name' do
        context 'decision transition doesnt exist' do
          it 'returns nil' do
            draft_claim = create :advocate_claim
            expect(draft_claim.last_decision_transition).to be_nil
            presenter = ClaimCsvPresenter.new(claim, view)
            expect(presenter.case_worker).to be_nil
          end
        end

        context 'author_id on the decision transition is nil' do
          it 'returns nil' do
            transition = claim.last_decision_transition
            transition.update_author_id(nil)
            presenter = ClaimCsvPresenter.new(claim, view)
            expect(presenter.case_worker).to be_nil
          end
        end

        context 'a decided claim' do
          it 'returns name of the caseworker that made the decision' do
            authorised_claim = create :authorised_claim
            transition = authorised_claim.last_decision_transition
            case_worker_name = transition.author.name
            presenter = ClaimCsvPresenter.new(authorised_claim, view)
            expect(presenter.case_worker).to eq case_worker_name
          end
        end

        context 'an allocated claim' do
          it 'returns the name of the caseworker allocated to the claim' do
            allocated_claim = create :allocated_claim
            case_worker_name = allocated_claim.case_workers.first.name
            presenter = ClaimCsvPresenter.new(allocated_claim, view)
            expect(presenter.case_worker).to eq case_worker_name
          end
        end

      end

      context 'and unique values for' do
        before { Timecop.freeze(Time.now) }
        after  { Timecop.return }

        it 'submission type' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include('new')
            expect(claim_journeys.second).to include('redetermination')
          end
        end

        it 'date submitted' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include((Time.zone.now - 3.day).strftime('%d/%m/%Y'))
            expect(claim_journeys.second).to include((Time.zone.now).strftime('%d/%m/%Y'))
          end
        end

        it 'date allocated' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include((Time.zone.now - 2.day).strftime('%d/%m/%Y'))
            expect(claim_journeys.second).to include('n/a', 'n/a')
          end
        end

        it 'date of last assessment' do
          subject.present! do |claim_journeys|
            expect(claim_journeys.first).to include((Time.zone.now - 1.day).strftime('%d/%m/%Y'))
            expect(claim_journeys.second).to include('n/a', 'n/a')
          end
        end

        it 'current/end state' do
          subject.present! do |claim_journeys|
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
          ClaimCsvPresenter.new(claim, view).present! do |csv|
            expect(csv[0]).not_to include('deallocated')
          end
        end

        it 'and the claim should be refelcted as being in the state prior to allocation' do
          ClaimCsvPresenter.new(claim, view).present! do |csv|
            expect(csv[0]).to include('submitted')
          end
        end
      end

      context 'state transitions reasons' do
        let(:claim) { create(:allocated_claim) }

        context 'rejected with a single reason as a string ' do
          before do
            claim.reject!(reason_code: ['no_rep_order'])
          end

          it 'the rejection reason code should be reflected in the MI' do
            allow_any_instance_of(ClaimStateTransition).to receive(:reason_code).and_return('no_rep_order')
            ClaimCsvPresenter.new(claim, view).present! do |csv|
              expect(csv[0][11]).to eq('no_rep_order')
            end
          end
        end

        context 'rejected with a single reason' do
          before do
            claim.reject!(reason_code: ['no_rep_order'])
          end

          it 'the rejection reason code should be reflected in the MI' do
            ClaimCsvPresenter.new(claim, view).present! do |csv|
              expect(csv[0][11]).to eq('no_rep_order')
            end
          end
        end

        context 'rejected with a multiple reasons' do
          before do
            claim.reject!(reason_code: ['no_rep_order', 'wrong_case_no'])
          end

          it 'the rejection reason code should be reflected in the MI' do
            ClaimCsvPresenter.new(claim, view).present! do |csv|
              expect(csv[0][11]).to eq('no_rep_order, wrong_case_no')
            end
          end
        end

        context 'rejected with other' do
          before do
            claim.reject!(reason_code: ['other'], reason_text: 'Rejection reason')
          end

          it 'the rejection reason code should be reflected in the MI' do
            ClaimCsvPresenter.new(claim, view).present! do |csv|
              expect(csv[0][11]).to eq('other')
              expect(csv[0][12]).to eq('Rejection reason')
            end
          end
        end

        context 'refused with a single reason as a string ' do
          before do
            claim.refuse!(reason_code: ['no_rep_order'])
          end

          it 'the refusal reason code should be reflected in the MI' do
            allow_any_instance_of(ClaimStateTransition).to receive(:reason_code).and_return('no_rep_order')
            ClaimCsvPresenter.new(claim, view).present! do |csv|
              expect(csv[0][11]).to eq('no_rep_order')
            end
          end
        end

        context 'refused with a single reason' do
          before do
            claim.refuse!(reason_code: ['no_rep_order'])
          end

          it 'the refusal reason code should be reflected in the MI' do
            ClaimCsvPresenter.new(claim, view).present! do |csv|
              expect(csv[0][11]).to eq('no_rep_order')
            end
          end
        end

        context 'refused with multiple reasons' do
          before do
            claim.refuse!(reason_code: ['no_rep_order', 'wrong_case_no'])
          end

          it 'the refusal reason code should be reflected in the MI' do
            ClaimCsvPresenter.new(claim, view).present! do |csv|
              expect(csv[0][11]).to eq('no_rep_order, wrong_case_no')
            end
          end
        end

        context 'rejected with other' do
          before do
            claim.reject!(reason_code: ['other'], reason_text: 'Rejection reason')
          end

          it 'the rejection reason code should be reflected in the MI' do
            ClaimCsvPresenter.new(claim, view).present! do |csv|
              expect(csv[0][11]).to eq('other')
              expect(csv[0][12]).to eq('Rejection reason')
            end
          end
        end
      end
    end
  end
end
