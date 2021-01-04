require 'rails_helper'

RSpec.describe Claims::Search do
  describe '#search' do
    let(:searchable) { Claim::BaseClaim }
    let(:term) { 'search_term' }
    let(:states) { [] }
    let(:options) { [] }
    let(:draft_claim) { create(:litigator_claim, :draft) }
    let(:authorised_claim) { create(:litigator_claim, :authorised) }
    let(:part_authorised_claim) {
      create(:litigator_claim, :part_authorised).tap do |claim|
        create_list(:defendant, 3, claim: claim)
      end
    }
    let(:rejected_claim) { create(:litigator_claim, :rejected) }
    let(:refused_claim) {
      create(:litigator_claim, :refused).tap do |claim|
        create_list(:defendant, 2, claim: claim)
      end
    }
    let(:archived_pending_delete_claim) { create(:litigator_claim, :archived_pending_delete) }
    let(:archived_pending_review_claim) { create(:hardship_archived_pending_review_claim) }

    # NOTE: Claim::BaseClaim is including this module, hence testing
    # it on the claim class itself
    subject(:query) { searchable.search(term, states, *options) }

    before do
      draft_claim
      authorised_claim
      part_authorised_claim
      rejected_claim
      refused_claim
      archived_pending_delete_claim
      archived_pending_review_claim
    end

    context 'for archived claims' do
      let(:searchable) { Claim::BaseClaim.active.caseworker_dashboard_archived }
      let(:states) { Claims::StateMachine::CASEWORKER_DASHBOARD_ARCHIVED_STATES }
      let(:options) { %i[case_number maat_reference defendant_name] }

      context 'when no search terms were provided' do
        let(:term) { '' }

        it 'does not include related filters in the SQL query' do
          filters = [
            /claims.case_number ILIKE/,
            /representation_orders.maat_reference ILIKE/,
            %r{lower(defendants.first_name || ' ' || defendants.last_name) ILIKE}
          ]
          filters.each do |filter|
            expect(query.to_sql).not_to match(filter)
          end
        end

        it 'returns all archived claims' do
          expected_claim_ids = [authorised_claim, part_authorised_claim, rejected_claim, refused_claim, archived_pending_delete_claim, archived_pending_review_claim].map(&:id)
          expect(query.count).to eq(6)
          expect(query.map(&:id)).to match_array(expected_claim_ids)
        end
      end

      context 'when a search term is provided' do
        let(:term) { '158' }
        let(:draft_claim) { create(:litigator_claim, :draft, case_number: 'T20222665') }
        let(:authorised_claim) {
          create(
            :litigator_claim, :authorised,
            case_number: 'T20158665',
            defendants: [
              create(
                :defendant,
                first_name: 'Rupert', last_name: 'Doe',
                representation_orders: [create(:representation_order, maat_reference: '4444444444')]
              )
            ]
          )
        }
        let(:part_authorised_claim) {
          create(
            :litigator_claim, :part_authorised,
            case_number: 'T20444665',
            defendants: [
              create(
                :defendant,
                first_name: 'First 158', representation_orders: [create(:representation_order, maat_reference: '4444444111')]
              ),
              create(
                :defendant,
                last_name: '158 Last', representation_orders: [create(:representation_order, maat_reference: '4444444222')]
              ),
              create(
                :defendant,
                first_name: 'John', last_name: 'Doe',
                representation_orders: [
                  create(:representation_order, maat_reference: '4444444333'),
                  create(:representation_order, maat_reference: '4444444666')
                ]
              )
            ]
          )
        }
        let(:rejected_claim) {
          create(
            :litigator_claim, :rejected,
            case_number: 'T20999665',
            defendants: [
              create(
                :defendant,
                first_name: 'Olivia', last_name: 'Doe',
                representation_orders: [
                  create(:representation_order, maat_reference: '5555555555')
                ]
              )
            ]
          )
        }
        let(:refused_claim) {
          create(
            :litigator_claim, :refused,
            case_number: 'T20555665',
            defendants: [
              create(
                :defendant,
                first_name: 'Peter', last_name: 'Doe',
                representation_orders: [
                  create(:representation_order, maat_reference: '7777777777')
                ]
              ),
              create(
                :defendant,
                first_name: 'Silvia', last_name: 'Doe',
                representation_orders: [
                  create(:representation_order, maat_reference: '9999999999')
                ]
              )
            ]
          )
        }
        let(:archived_pending_delete_claim) {
          create(
            :litigator_claim, :archived_pending_delete,
            case_number: 'T20111665',
            defendants: [
              create(
                :defendant,
                first_name: 'Jane', last_name: 'Doe',
                representation_orders: [
                  create(:representation_order, maat_reference: '1111158')
                ]
              )
            ]
          )
        }
        let(:archived_pending_review_claim) {
          create(
            :hardship_archived_pending_review_claim,
            case_number: 'T20751665',
            defendants: [
              create(
                :defendant,
                first_name: 'Mary', last_name: 'Doe',
                representation_orders: [
                  create(:representation_order, maat_reference: '1111158')
                ]
              )
            ]
          )
        }

        it 'includes related filters in the SQL query' do
          filters = [
            /claims.case_number ILIKE '%#{term}%'/,
            /representation_orders.maat_reference ILIKE '%#{term}%'/,
            /lower\(defendants.first_name || ' ' || defendants.last_name\) ILIKE '%#{term}%'/
          ]
          filters.each do |filter|
            expect(query.to_sql).to match(filter)
          end
        end

        it 'returns all matching archived claims' do
          expected_claim_ids = [authorised_claim, part_authorised_claim, archived_pending_delete_claim, archived_pending_review_claim].map(&:id)
          expect(query.count).to eq(4)
          expect(query.map(&:id)).to match_array(expected_claim_ids)
        end
      end
    end
  end
end
