require 'rails_helper'

RSpec.describe ClaimHistoryPresenter do
  let(:claim) { create :claim }
  subject { ClaimHistoryPresenter.new(claim, view) }

  describe '#history_and_messages' do
    let(:first_message) do
      Timecop.travel(Time.zone.local(2015, 9, 21, 13, 0, 0)) do
        create(:message, claim: claim, body: 'Hello world')
      end
    end

    let(:second_message) do
      Timecop.travel(Time.zone.local(2015, 9, 21, 14, 0, 0)) do
        create(:message, claim: claim, body: 'Lorem ipsum')
      end
    end

    let(:third_message) do
      Timecop.travel(Time.zone.local(2015, 9, 23, 14, 0, 0)) do
        create(:message, claim: claim, body: 'Lorem ipsum')
      end
    end

    let!(:expected_hash) do
      Timecop.travel(Time.zone.local(2015, 9, 21, 13, 50, 9)) do
        claim.submit!
      end

      Timecop.travel(Time.zone.local(2015, 9, 24, 14, 0, 0)) do
        claim.assessment.fees = 100
        claim.assessment.expenses = 200
        claim.assessment.save
      end

      claim.reload

      hash = {
        '21/09/2015' => [
          first_message,
          claim.versions.last,
          second_message
        ],
        '23/09/2015' => [
          third_message,
        ],
        '24/09/2015' => [
          claim.assessment.versions.last
        ]
      }

      hash
    end

    it 'returns an claims message and history hash in chronological order' do
      claim.reload
      expect(subject.history_and_messages).to eq(expected_hash)
    end
  end
end
