require 'rails_helper'

RSpec.describe ClaimHistoryPresenter do
  let(:claim) { create :claim }
  subject { ClaimHistoryPresenter.new(claim, view) }

  describe '#history_items_by_date' do
    let(:first_message) do
      travel_to(Time.zone.local(2015, 9, 21, 13, 0, 0)) do
        create(:message, claim: claim, body: 'Hello world')
      end
    end

    let(:second_message) do
      travel_to(Time.zone.local(2015, 9, 21, 14, 0, 0)) do
        create(:message, claim: claim, body: 'Lorem ipsum')
      end
    end

    let(:third_message) do
      travel_to(Time.zone.local(2015, 9, 23, 14, 0, 0)) do
        create(:message, claim: claim, body: 'Lorem ipsum')
      end
    end

    let(:first_redetermination) do
      travel_to(Time.zone.local(2015, 9, 25, 14, 0, 0)) do
        claim.redeterminations.create(fees: 500, expenses: 300, disbursements: 0)
        claim.redeterminations.last.versions.last
      end
    end

    let(:assessment) do
      travel_to(Time.zone.local(2015, 9, 24, 14, 0, 0)) do
        claim.assessment.fees = 100
        claim.assessment.expenses = 200
        claim.assessment.disbursements = 0
        claim.assessment.save
        claim.assessment.versions.last
      end
    end

    let!(:expected_hash) do
      travel_to(Time.zone.local(2015, 9, 21, 13, 50, 9)) do
        claim.submit!
      end

      claim.reload

      hash = {
        '21/09/2015' => [
          first_message,
          claim.claim_state_transitions.first,
          second_message
        ],
        '23/09/2015' => [
          third_message
        ],
        '24/09/2015' => [
          assessment
        ],
        '25/09/2015' => [
          first_redetermination
        ]
      }

      hash
    end

    it 'returns a claims message and history hash in chronological order' do
      claim.reload
      expect(subject.history_items_by_date).to eq(expected_hash)
    end
  end
end
