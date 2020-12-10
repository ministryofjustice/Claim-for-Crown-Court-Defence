require 'rails_helper'

RSpec.describe ClaimReporter do
  before(:all) do
    @draft_claim_1 = create(:draft_claim, form_id: SecureRandom.uuid)
    @authorised_claim_1 = create(:authorised_claim, authorised_at: Time.now, form_id: SecureRandom.uuid)
    @submitted_claim_1 = create(:submitted_claim, form_id: SecureRandom.uuid)
    @allocated_claim_1 = create(:allocated_claim, form_id: SecureRandom.uuid)
    @allocated_claim_2 = create(:allocated_claim, form_id: SecureRandom.uuid)
    @part_authorised_claim_1 = create(:part_authorised_claim, authorised_at: Time.now, form_id: SecureRandom.uuid)
    @part_authorised_claim_2 = create(:part_authorised_claim, authorised_at: Time.now, form_id: SecureRandom.uuid)
    @rejected_claim_1 = create(:rejected_claim, form_id: SecureRandom.uuid)
    @rejected_claim_2 = create(:rejected_claim, form_id: SecureRandom.uuid)

    @old_part_authorised_claim = create(:part_authorised_claim, form_id: SecureRandom.uuid).update_column(:authorised_at, 5.weeks.ago)
    @old_rejected_claim = create(:rejected_claim, form_id: SecureRandom.uuid).last_state_transition.update_column(:created_at, 5.weeks.ago)
  end

  after(:all) do
    clean_database
  end


  subject { ClaimReporter.new }

  describe '#completion_rate' do
    before do
      travel -5.weeks do
        create(:claim_intention, form_id: @submitted_claim_1.form_id)
        create(:claim_intention, form_id: @allocated_claim_1.form_id)

        create(:claim_intention, form_id: SecureRandom.uuid)
        create(:claim_intention, form_id: SecureRandom.uuid)
      end
    end

    it 'returns the completion rate for claims in the last 16 weeks' do
      expect(subject.completion_rate).to eq(50.0)
    end
  end
end
